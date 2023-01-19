USE [DBF_NAH]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[dbo].[COURIER_PAY_CALC_DEFAULT]', 'P ') IS NULL EXEC('CREATE PROCEDURE [dbo].[COURIER_PAY_CALC_DEFAULT]  AS SELECT 1')
GO
ALTER PROCEDURE [dbo].[COURIER_PAY_CALC_DEFAULT]
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

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END

GO
GRANT EXECUTE ON [dbo].[COURIER_PAY_CALC_DEFAULT] TO rl_courier_pay;
GO
