USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[Price].[PRICE_DBF_IMPORT]', 'P ') IS NULL EXEC('CREATE PROCEDURE [Price].[PRICE_DBF_IMPORT]  AS SELECT 1')
GO
ALTER PROCEDURE [Price].[PRICE_DBF_IMPORT]
	@DBFMonth		UniqueIdentifier,
	@ClientMonth	UniqueIdentifier
WITH EXECUTE AS OWNER
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE
		@DebugError		VarChar(512),
		@DebugContext	Xml,
		@Params			Xml;

	DECLARE
		@DBFDate		SmallDateTime,
		@ClientDate		SmallDateTime;

	EXEC [Debug].[Execution@Start]
		@Proc_Id		= @@ProcId,
		@Params			= @Params,
		@DebugContext	= @DebugContext OUT

	BEGIN TRY

		SELECT @DBFDate = START
		FROM [Common].[Period]
		WHERE [ID] = @DBFMonth;

		SELECT @ClientDate = START
		FROM [Common].[Period]
		WHERE [ID] = @ClientMonth;

		DECLARE @DBFPrice Table
		(
			SYS_REG		VarChar(50)		NOT NULL,
			PRICE		Money			NOT NULL,
			PRIMARY KEY CLUSTERED(SYS_REG)
		);

		INSERT INTO @DBFPrice
		SELECT SYS_REG_NAME, PS_PRICE
		FROM dbo.DBFPriceView
		WHERE PR_DATE = @DBFDate

        -- удялем данные за целевой месяц, мы ведь сейчас загрузим новые
		DELETE
		FROM Price.SystemPrice
		WHERE ID_MONTH = @ClientMonth;

		INSERT INTO Price.SystemPrice(ID_SYSTEM, ID_MONTH, PRICE)
		SELECT
			[SystemId]		= S.[SystemId],
			[MonthId]		= @ClientMonth,
			[Price]			= D.[PRICE]
		FROM @DBFPrice D
		INNER JOIN dbo.SystemTable S ON S.SystemBaseName = D.SYS_REG;

		UPDATE P SET
			[Price] = D.[PRICE]
		FROM @DBFPrice AS D
		INNER JOIN dbo.SystemTable S ON S.[SystemBaseName] = D.[SYS_REG]
		INNER JOIN [Price].[Systems:Price@Get](@ClientDate) AS PD ON PD.[System_Id] = S.[SystemID]
		INNER JOIN [Price].[System:Price] AS P ON P.[Date] = @ClientDate AND P.[System_Id] = S.[SystemID]
		WHERE P.[Price] != D.[PRICE];

		INSERT INTO [Price].[System:Price]([System_Id], [Date], [Price])
		SELECT S.[SystemID], @ClientDate, D.[PRICE]
		FROM @DBFPrice AS D
		INNER JOIN dbo.SystemTable S ON S.[SystemBaseName] = D.[SYS_REG]
		INNER JOIN [Price].[Systems:Price@Get](@ClientDate) AS P ON P.[System_Id] = S.[SystemID]
		WHERE NOT EXISTS
			(
				SELECT *
				FROM [Price].[System:Price] AS SP
				WHERE SP.[System_Id] = S.[SystemID]
					AND SP.[Date] = @ClientDate
			);

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [Price].[PRICE_DBF_IMPORT] TO rl_price_import;
GO
