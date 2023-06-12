USE [DBF]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[Salary].[CALC_DEFAULT_GET]', 'P ') IS NULL EXEC('CREATE PROCEDURE [Salary].[CALC_DEFAULT_GET]  AS SELECT 1')
GO
ALTER PROCEDURE [Salary].[CALC_DEFAULT_GET]
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

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [Salary].[CALC_DEFAULT_GET] TO rl_courier_pay;
GO
