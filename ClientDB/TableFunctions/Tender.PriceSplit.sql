USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[Tender].[PriceSplit]', 'TF') IS NULL EXEC('CREATE FUNCTION [Tender].[PriceSplit] () RETURNS @output TABLE(Id Int) AS BEGIN RETURN END')
GO
CREATE FUNCTION [Tender].[PriceSplit]
(
	@LIST		NVARCHAR(MAX),
	@MONTH		UNIQUEIDENTIFIER,
	@TOTAL		MONEY
)
RETURNS @TBL TABLE
(
	SystemID	INT,
	DistrTypeID	INT,
	CNT			INT,
	PRICE		MONEY
)
AS
BEGIN
	DECLARE
		@XML	Xml,
		@Date	SmallDateTime;

	SET @XML = CAST(@LIST AS XML)

	DECLARE @RES TABLE
		(
			SystemID	INT,
			DistrTypeID	INT,
			CNT			INT,
			TOTAL_PRICE	MONEY
		)

	SELECT @Date = START
	FROM [Common].[Period]
	WHERE [ID] = @MONTH;

	INSERT INTO @RES(SystemID, DistrTypeID, CNT, TOTAL_PRICE)
		SELECT
			SystemID, DistrTypeID, COUNT(*) AS CNT, PRICE_TOTAL
		FROM
			(
				SELECT
					b.SystemID,
					DistrTypeID,
					CONVERT(MONEY, ROUND(PRICE * dbo.DistrCoef(a.SYS_ID, a.NET_ID, NULL, @DATE), 0)) AS PRICE_TOTAL
				FROM
					(
						SELECT
							c.value('(@sys)', 'INT') AS SYS_ID,
							c.value('(@net)', 'INT') AS NET_ID
						FROM @xml.nodes('/root/item') AS a(c)
					) AS a
					INNER JOIN dbo.SystemTable b ON a.SYS_ID = b.SystemID
					INNER JOIN dbo.DistrTypeTable c ON a.NET_ID = c.DistrTypeID
					INNER JOIN [Price].[Systems:Price@Get](@Date) AS D ON D.[System_Id] = [SYS_ID]
			) AS o_O
		GROUP BY SystemID, DistrTypeID, PRICE_TOTAL

		DECLARE @KEY_SYSTEM	INT
		DECLARE @KEY_DISTR	INT

		IF EXISTS
			(
				SELECT *
				FROM @RES
				WHERE CNT = 1
			)
			SELECT TOP 1 @KEY_SYSTEM = a.SystemID, @KEY_DISTR = a.DistrTypeID
			FROM
				@RES a
				INNER JOIN dbo.SystemTable b ON a.SystemID = b.SystemID
				INNER JOIN dbo.DistrTypeTable c ON c.DistrTypeID = a.DistrTypeID
			WHERE CNT = 1
			ORDER BY SystemOrder DESC, DistrTypeOrder
		ELSE
			SELECT TOP 1 @KEY_SYSTEM = a.SystemID, @KEY_DISTR = a.DistrTypeID
			FROM
				@RES a
				INNER JOIN dbo.SystemTable b ON a.SystemID = b.SystemID
				INNER JOIN dbo.DistrTypeTable c ON c.DistrTypeID = a.DistrTypeID
			ORDER BY CNT DESC, SystemOrder DESC, DistrTypeOrder

		/*SELECT @KEY_SYSTEM, @KEY_DISTR*/

		DECLARE @SPLIT TABLE
			(
				SystemID	INT,
				DistrTypeID	INT,
				CNT			INT,
				PRICE		MONEY
			)

		;WITH t AS
		(
			SELECT SystemID, DistrTypeID, CNT, TOTAL_PRICE
			FROM @RES
		),
		x AS
		(
			SELECT
				SystemID, DistrTypeID, CNT, TOTAL_PRICE,
				CASE
					WHEN SystemID = @KEY_SYSTEM AND DistrTypeID = @KEY_DISTR THEN 0
					ELSE CONVERT(MONEY,
							FLOOR(
								@TOTAL * CNT * TOTAL_PRICE /

								SUM(CNT * TOTAL_PRICE) OVER(PARTITION BY 1) / CNT) * CNT
						)
				END PRICE
			FROM t
		)
			INSERT INTO @SPLIT(SystemID, DistrTypeID, CNT, PRICE)
				SELECT
					SystemID, DistrTypeID, CNT,
					CASE
						WHEN SystemID = @KEY_SYSTEM AND DistrTypeID = @KEY_DISTR THEN @TOTAL - SUM(PRICE) OVER(PARTITION BY 1)
						ELSE PRICE
					END PRICE
				FROM x

	INSERT INTO @TBL(SystemID, DistrTypeID, CNT, PRICE)
		SELECT SystemID, DistrTypeID, CNT, ROUND(PRICE/CNT, 2)
		FROM @SPLIT

	RETURN
END
GO
