USE [DBF]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


/*
Автор:			Денисов Алексей/Богдан Владимир
Дата создания:  	
Описание:		
*/

CREATE PROCEDURE [dbo].[INCOME_UNCONVEY_DISTR]
	@idid VARCHAR(MAX)
AS
BEGIN
	SET NOCOUNT ON;

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
END





