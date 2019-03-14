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

CREATE PROCEDURE [dbo].[CLIENT_PERIOD_SELECT]
	@clientid INT
AS
BEGIN
	SET NOCOUNT ON;

	-- Текст процедуры ниже
	SELECT DISTINCT PR_ID, PR_DATE, PR_NAME, PR_END_DATE
	FROM 
		dbo.PeriodTable INNER JOIN
		dbo.BillTable ON BL_ID_PERIOD = PR_ID
	WHERE BL_ID_CLIENT = @clientid
	ORDER BY PR_DATE DESC
END

