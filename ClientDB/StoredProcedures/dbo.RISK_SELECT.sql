USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[dbo].[RISK_SELECT]', 'P ') IS NULL EXEC('CREATE PROCEDURE [dbo].[RISK_SELECT]  AS SELECT 1')
GO
ALTER PROCEDURE [dbo].[RISK_SELECT]
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
			SEARCH_MON, SEARCH_CNT,
			DUTY_MON, DUTY_CNT,
			RIVAL_MON, RIVAL_CNT,
			UPD_WEEK, UPD_CNT,
			STUDY_MON, STUDY_CNT,
			SEMINAR_MON, SEMINAR_CNT
		FROM dbo.Risk
		WHERE STATUS = 1

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [dbo].[RISK_SELECT] TO rl_risk_ref;
GO
