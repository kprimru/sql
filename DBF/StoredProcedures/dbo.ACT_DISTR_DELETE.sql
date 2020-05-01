USE [DBF]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



/*
Автор:			Денисов Алексей/Богдан Владимир
Описание:		
*/

ALTER PROCEDURE [dbo].[ACT_DISTR_DELETE]
	@actid VARCHAR(MAX)
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

		IF OBJECT_ID('tempdb..#act') IS NOT NULL
			DROP TABLE #act

		CREATE TABLE #act
			(
				aid INT
			)

		IF @actid IS NOT NULL
			BEGIN
				--парсить строчку и выбирать нужные значения
				INSERT INTO #act
					SELECT DISTINCT * FROM dbo.GET_TABLE_FROM_LIST(@actid, ',')
			END

		INSERT INTO dbo.FinancingProtocol(ID_CLIENT, ID_DOCUMENT, TP, OPER, TXT)
			SELECT 
				ACT_ID_CLIENT, ACT_ID, 'ACT', 'Удаление строки акта', 
				CONVERT(VARCHAR(20), PR_DATE, 104) + ' ' + DIS_STR + ' - ' + dbo.MoneyFormat(AD_TOTAL_PRICE)
			FROM 
				dbo.ActTable a
				INNER JOIN dbo.ActDistrTable b ON a.ACT_ID = b.AD_ID
				INNER JOIN #act c ON aid = AD_ID
				INNER JOIN dbo.DistrView WITH(NOEXPAND) ON DIS_ID = AD_ID_DISTR
				INNER JOIN dbo.PeriodTable ON PR_ID = AD_ID_PERIOD

		DELETE 
		FROM dbo.SaldoTable
		WHERE SL_ID_ACT_DIS IN (SELECT aid FROM #act)
		
		DELETE FROM dbo.ActDistrTable
		WHERE AD_ID IN (SELECT aid FROM #act)

		IF OBJECT_ID('tempdb..#act') IS NOT NULL
			DROP TABLE #act
			
		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();
		
		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;
		
		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GRANT EXECUTE ON [dbo].[ACT_DISTR_DELETE] TO rl_act_d;
GO