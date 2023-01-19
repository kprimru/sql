USE [DBF]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[dbo].[INCOME_UNCONVEY_DISTR]', 'P ') IS NULL EXEC('CREATE PROCEDURE [dbo].[INCOME_UNCONVEY_DISTR]  AS SELECT 1')
GO


/*
Автор:			Денисов Алексей/Богдан Владимир
Дата создания:  
Описание:
*/

ALTER PROCEDURE [dbo].[INCOME_UNCONVEY_DISTR]
	@idid VARCHAR(MAX)
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE
		@DebugError		VarChar(512),
		@DebugContext	Xml,
		@Params			Xml;

	EXEC [Debug].[Execution@Start]
		@Proc_Id		= @@ProcId,
		@Params			= @Params,
		@DebugContext	= @DebugContext OUT

	BEGIN TRY

		IF OBJECT_ID('tempdb..#income') IS NOT NULL
			DROP TABLE #income

		CREATE TABLE #income
			(
				incomeid INT
			)

		IF @idid IS NOT NULL
			BEGIN
				--парсить строчку и выбирать нужные значения
				INSERT INTO #income
					SELECT DISTINCT * FROM dbo.GET_TABLE_FROM_LIST(@idid, ',')
			END

		DELETE FROM dbo.SaldoTable
		WHERE SL_ID_IN_DIS IN (SELECT incomeid FROM #income)

		DELETE FROM dbo.IncomeDistrTable
		WHERE ID_ID IN (SELECT incomeid FROM #income)

		IF OBJECT_ID('tempdb..#income') IS NOT NULL
			DROP TABLE #income

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [dbo].[INCOME_UNCONVEY_DISTR] TO rl_income_w;
GO
