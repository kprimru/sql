USE [DBF_NAH]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[dbo].[ACTION_GET]', 'P ') IS NULL EXEC('CREATE PROCEDURE [dbo].[ACTION_GET]  AS SELECT 1')
GO
ALTER PROCEDURE [dbo].[ACTION_GET]
	@ID	SMALLINT
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
			ACTN_ID, ACTN_NAME, ACTT_ID, ACTT_NAME, ACTN_BEGIN, ACTN_END, ACTN_ACTIVE,
			REVERSE(STUFF(REVERSE(
				(
					SELECT CONVERT(VARCHAR(20), AP_ID_PERIOD) + ','
					FROM dbo.ActionPeriod
					WHERE AP_ID_AC = ACTN_ID
					ORDER BY AP_ID_PERIOD FOR XML PATH('')
				)), 1, 1, '')) AS ACTN_MONTH_ID,
			REVERSE(STUFF(REVERSE(
				(
					SELECT CONVERT(VARCHAR(20), PR_NAME) + ','
					FROM
						dbo.ActionPeriod
						INNER JOIN dbo.PeriodTable ON PR_ID = AP_ID_PERIOD
					WHERE AP_ID_AC = ACTN_ID
					ORDER BY PR_DATE FOR XML PATH('')
				)), 1, 1, '')) AS ACTN_MONTH
		FROM
			dbo.Action
			INNER JOIN dbo.ActionType ON ACTT_ID = ACTN_ID_TYPE
		WHERE ACTN_ID = @ID

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END

GO
GRANT EXECUTE ON [dbo].[ACTION_GET] TO rl_action_r;
GO
