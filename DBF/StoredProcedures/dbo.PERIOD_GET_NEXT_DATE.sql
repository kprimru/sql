USE [DBF]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
Автор:			
Дата создания:  	
Описание:		
*/

CREATE PROCEDURE [dbo].[PERIOD_GET_NEXT_DATE]
	@periodid SMALLINT
AS
BEGIN
	SET NOCOUNT ON;

	SELECT CONVERT(VARCHAR, DATEPART(d, PR_DATE)) + ' ' + DATENAME(mm, PR_DATE) + ' ' + DATENAME(yyyy, PR_DATE) + ' года' AS PR_STR
	FROM dbo.PeriodTable
	WHERE PR_ID = @periodid
END

