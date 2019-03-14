USE [DBF]
	GO
	SET ANSI_NULLS ON
	GO
	SET QUOTED_IDENTIFIER ON
	GO
	CREATE PROCEDURE [dbo].[COURIER_PAY_CALC_DEFAULT]
AS
BEGIN
	SET NOCOUNT ON;

	SELECT 
		PR_ID, PR_NAME,
		REVERSE(STUFF(REVERSE(
			(
				SELECT CONVERT(VARCHAR(MAX), COUR_ID) + ','
				FROM dbo.CourierTable
				WHERE COUR_ID_TYPE = 2
				ORDER BY COUR_ID FOR XML PATH('')
			)), 1, 1, '')) AS COUR_ID,
		REVERSE(STUFF(REVERSE(
			(
				SELECT COUR_NAME + ','
				FROM dbo.CourierTable
				WHERE COUR_ID_TYPE = 2
				ORDER BY COUR_NAME FOR XML PATH('')
			)), 1, 1, '')) AS COUR_NAME
	FROM dbo.PeriodTable
	WHERE PR_ID = dbo.PERIOD_PREV(dbo.GET_PERIOD_BY_DATE(GETDATE()))
END