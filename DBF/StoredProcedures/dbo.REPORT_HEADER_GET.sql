USE [DBF]
	GO
	SET ANSI_NULLS ON
	GO
	SET QUOTED_IDENTIFIER ON
	GO
	




/*
Автор:		  Денисов Алексей
Описание:	  
*/

CREATE PROCEDURE [dbo].[REPORT_HEADER_GET]	
	@prid SMALLINT
AS
BEGIN
	SET NOCOUNT ON;	

    SELECT	'Отчет РИЦ ' + (SELECT dbo.GET_SETTING('REPORT_RIC_NUM')) + 
			' по клиентам КонсультантПлюс за ' + CONVERT(VARCHAR, DATENAME(mm, PR_DATE)) + ' ' + CONVERT(VARCHAR, DATENAME(yyyy, PR_DATE)) + 
           ' года, ответственный ' + (SELECT dbo.GET_SETTING('REPORT_NAME')) AS RPT_HEADER
	FROM dbo.PeriodTable
	WHERE PR_ID = @prid
END












