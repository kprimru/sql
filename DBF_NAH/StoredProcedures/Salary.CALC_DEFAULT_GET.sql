USE [DBF_NAH]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [Salary].[CALC_DEFAULT_GET]
AS
BEGIN
	SET NOCOUNT ON;

	SELECT PR_ID, PR_DATE,
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
	FROM
		(
			SELECT TOP 1 ID_COURIER, ID_PERIOD
			FROM Salary.Service
			ORDER BY LAST DESC
		) AS a
		INNER JOIN dbo.PeriodTable ON PR_ID = ID_PERIOD
		--INNER JOIN dbo.CourierTable ON COUR_ID = ID_COURIER
END

GO
GRANT EXECUTE ON [Salary].[CALC_DEFAULT_GET] TO rl_courier_pay;
GO