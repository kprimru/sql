USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[Tender].[DISTR_PRICE_GET]', 'P ') IS NULL EXEC('CREATE PROCEDURE [Tender].[DISTR_PRICE_GET]  AS SELECT 1')
GO
CREATE OR ALTER PROCEDURE [Tender].[DISTR_PRICE_GET]
	@LIST		NVARCHAR(MAX),
	@TYPE		TINYINT,
	@MONTH		UNIQUEIDENTIFIER,
	@DISCOUNT	DECIMAL(8, 4),
	@INFLATION	DECIMAL(8, 4),
	@SPREAD		MONEY
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE
		@DebugError		VarChar(512),
		@DebugContext	Xml,
		@Params			Xml;

	DECLARE
		@XML			Xml,
		@Date			SmallDateTime;

	EXEC [Debug].[Execution@Start]
		@Proc_Id		= @@ProcId,
		@Params			= @Params,
		@DebugContext	= @DebugContext OUT

	BEGIN TRY

		SET @XML = CAST(@LIST AS XML);

		SELECT @Date = [START]
		FROM [Common].[Period]
		WHERE [ID] = @MONTH;

		IF @TYPE = 1
			SELECT ID, PRICE
			FROM
				(
					SELECT
						a.ID,
						CONVERT(MONEY, ROUND(PRICE * PC.[DistrCoef] * (100 - @DISCOUNT) / 100 * (1 + @INFLATION / 100.0), 0)) AS PRICE
					FROM
						(
							SELECT
								c.value('(@id)', 'UNIQUEIDENTIFIER') AS ID,
								c.value('(@sys)', 'INT') AS SYS_ID,
								c.value('(@net)', 'INT') AS NET_ID
							FROM @xml.nodes('/root/item') AS a(c)
						) AS a
						INNER JOIN dbo.SystemTable b ON a.SYS_ID = b.SystemID
						-- TODO: не учитывается тип системы
						OUTER APPLY
						(
							SELECT
								[Price],
								[DistrCoef],
								[DistrCoefRound]
							FROM [Price].[DistrPriceWrapper](a.SYS_ID, a.NET_ID, NULL, NULL, @Date)
						) AS PC
				) AS o_O
		ELSE
			SELECT ID, PRICE
			FROM
				(
					SELECT
						c.value('(@id)', 'UNIQUEIDENTIFIER') AS ID,
						c.value('(@sys)', 'INT') AS SYS_ID,
						c.value('(@net)', 'INT') AS NET_ID
					FROM @xml.nodes('/root/item') AS a(c)
				) AS a
				INNER JOIN Tender.PriceSplit(@LIST, @MONTH, @SPREAD) b ON a.SYS_ID = b.SystemID AND a.NET_ID = b.DistrTypeID

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [Tender].[DISTR_PRICE_GET] TO rl_tender_u;
GO
