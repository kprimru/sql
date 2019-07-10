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

CREATE PROCEDURE [dbo].[ACT_DISTR_DELETE]
	@actid VARCHAR(MAX)
AS
BEGIN
	SET NOCOUNT ON;

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
			INNER JOIN dbo.DistrView ON DIS_ID = AD_ID_DISTR
			INNER JOIN dbo.PeriodTable ON PR_ID = AD_ID_PERIOD

	DELETE 
	FROM dbo.SaldoTable
	WHERE SL_ID_ACT_DIS IN (SELECT aid FROM #act)
	
	DELETE FROM dbo.ActDistrTable
	WHERE AD_ID IN (SELECT aid FROM #act)

	IF OBJECT_ID('tempdb..#act') IS NOT NULL
		DROP TABLE #act
END










