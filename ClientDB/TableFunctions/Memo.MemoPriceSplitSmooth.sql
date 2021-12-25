USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[Memo].[MemoPriceSplitSmooth]', 'TF') IS NULL EXEC('CREATE FUNCTION [Memo].[MemoPriceSplitSmooth] () RETURNS @output TABLE(Id Int) AS BEGIN RETURN END')
GO
ALTER FUNCTION [Memo].[MemoPriceSplitSmooth]
(
	@LIST		NVARCHAR(MAX),
	@MONTH		UNIQUEIDENTIFIER,
	@TOTAL_NDS	MONEY
)
RETURNS @TBL TABLE
(
	SystemID	INT,
	DistrTypeID	INT,
	CNT			INT,
	PRICE		MONEY,
	TAX_PRICE	MONEY,
	TOTAL_PRICE	MONEY
)
AS
BEGIN
	/*
	DECLARE @TBL TABLE
		(
			SystemID	INT,
			DistrTypeID	INT,
			CNT			INT,
			PRICE		MONEY,
			TAX_PRICE	MONEY,
			TOTAL_PRICE	MONEY
		)
	*/

	DECLARE @DATE SMALLDATETIME

	SELECT @DATE = START
	FROM Common.Period
	WHERE ID = @MONTH

	IF @DATE >= '20181001'
		SET @DATE = '20190101'

	DECLARE @TaxRate DECIMAL(8, 4)
	DECLARE @TotalRate DECIMAL(8, 4)

	SELECT @TaxRate = TAX_RATE, @TotalRate = TOTAL_RATE
	FROM Common.TaxDefaultSelect(@DATE)

	DECLARE @XML XML

	SET @XML = CAST(@LIST AS XML)

	DECLARE @RES TABLE
		(
			SystemID	INT,
			DistrTypeID	INT,
			CNT			INT,
			TOTAL_PRICE	MONEY
		)

	INSERT INTO @RES(SystemID, DistrTypeID, CNT, TOTAL_PRICE)
		SELECT
			SystemID, DistrTypeID, COUNT(*) AS CNT,
			CONVERT(MONEY, ROUND(PRICE_TOTAL * @TotalRate, 2)) AS TOTAL_PRICE
		FROM
			(
				SELECT
					CL_ID, CL_NUM, DISTR, COMP,
					b.SystemID, SystemShortName, b.SystemOrder,
					DistrTypeID, DistrTypeName, e.COEF, DistrTypeOrder,
					SystemTypeID, SystemTypeName,
					DISCOUNT, INFLATION,
					PRICE,
					CONVERT(MONEY, ROUND(PRICE * e.COEF * (100 - DISCOUNT) / 100 * (1 + INFLATION / 100.0), 0)) AS PRICE_TOTAL
				FROM
					(
						SELECT 
							c.value('(@client)', 'INT') AS CL_ID,
							c.value('(@num)', 'INT') AS CL_NUM,
							c.value('(@sys)', 'INT') AS SYS_ID,
							c.value('(@distr)', 'INT') AS DISTR,
							c.value('(@comp)', 'INT') AS COMP,
							c.value('(@net)', 'INT') AS NET_ID,
							c.value('(@type)', 'INT') AS TP_ID,
							c.value('(@discount)', 'INT') AS DISCOUNT,
							c.value('(@inflation)', 'INT') AS INFLATION
						FROM @xml.nodes('/root/item') AS a(c)
					) AS a
					INNER JOIN dbo.SystemTable b ON a.SYS_ID = b.SystemID
					INNER JOIN dbo.DistrTypeTable c ON a.NET_ID = c.DistrTypeID
					INNER JOIN Price.SystemPrice d ON ID_SYSTEM = SYS_ID
					INNER JOIN dbo.DistrTypeCoef e ON e.ID_NET = c.DistrTypeID AND e.ID_MONTH = @MONTH
					LEFT OUTER JOIN dbo.SystemTypeTable f ON f.SystemTypeID = a.TP_ID
				WHERE d.ID_MONTH = @MONTH
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
			ORDER BY CNT DESC, SystemOrder, DistrTypeOrder DESC

		/*SELECT @KEY_SYSTEM, @KEY_DISTR*/

		/*
		DECLARE @SPLIT TABLE
			(
				SystemID	INT,
				DistrTypeID	INT,
				CNT			INT,
				PRICE_NDS	MONEY
			)

		;WITH t AS
		(
			SELECT SystemID, DistrTypeID, CNT, TOTAL_PRICE
			FROM @RES
		),
		x AS
		(
			SELECT
				SystemID, DistrTypeID, CNT, TOTAL_PRICE, --CNT * TOTAL_PRICE AS TOTAL,
				CASE
					WHEN SystemID = @KEY_SYSTEM AND DistrTypeID = @KEY_DISTR THEN 0
					ELSE CONVERT(MONEY,
							/*ROUND(*/
							FLOOR(
								@TOTAL_NDS * CNT * TOTAL_PRICE /

								SUM(CNT * TOTAL_PRICE) OVER(PARTITION BY 1) / 1.18 / CNT/*,

								0*/) * 1.18 * CNT
						)
				end PRICE_NDS
			FROM t
		)
			INSERT INTO @SPLIT(SystemID, DistrTypeID, CNT, PRICE_NDS)
				SELECT
					SystemID, DistrTypeID, CNT,
					CASE
						WHEN SystemID = @KEY_SYSTEM AND DistrTypeID = @KEY_DISTR THEN @TOTAL_NDS - SUM(PRICE_NDS) OVER(PARTITION BY 1)
						ELSE PRICE_NDS
					END PRICE_NDS
				FROM x


	INSERT INTO @TBL(SystemID, DistrTypeID, CNT, PRICE, TAX_PRICE, TOTAL_PRICE)
		SELECT SystemID, DistrTypeID, CNT, PRICE, ROUND(PRICE * 1.18, 2) - PRICE, ROUND(PRICE * 1.18, 2)
		FROM
			(
				SELECT SystemID, DistrTypeID, CNT, CONVERT(MONEY, ROUND(PRICE_NDS / CNT / 1.18, 2)) AS PRICE, PRICE_NDS
				FROM @SPLIT
			) AS o_O
	*/

	DECLARE @CNT INT

	SELECT @CNT = SUM(CNT)
	FROM @RES

	INSERT INTO @TBL(SystemID, DistrTypeID, CNT, PRICE, TAX_PRICE, TOTAL_PRICE)
		SELECT SystemID, DistrTypeID, CNT, PRICE, ROUND(PRICE * @TotalRate, 2) - PRICE, ROUND(PRICE * @TotalRate, 2)
		FROM
			(
				SELECT SystemID, DistrTypeID, CNT, ROUND(@TOTAL_NDS / @CNT / @TotalRate, 2) AS PRICE
				FROM @RES
				WHERE SystemID <> @KEY_SYSTEM AND DistrTypeID <> @KEY_DISTR
			) AS o_O

	INSERT INTO @TBL(SystemID, DistrTypeID, CNT, PRICE, TAX_PRICE, TOTAL_PRICE)
		SELECT SystemID, DistrTypeID, CNT, PRICE, ROUND(PRICE * @TotalRate, 2) - PRICE, ROUND(PRICE * @TotalRate, 2)
		FROM
			(
				SELECT SystemID, DistrTypeID, CNT, ROUND((@TOTAL_NDS - (SELECT SUM(TOTAL_PRICE*CNT) FROM @TBL)) / CNT / @TotalRate, 2) AS PRICE
				FROM @RES
				WHERE SystemID = @KEY_SYSTEM AND DistrTypeID = @KEY_DISTR
			) AS o_O

	RETURN
END
GO
