USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[dbo].[CLIENT_STUDY_CLAIM_WORK_GET]', 'P ') IS NULL EXEC('CREATE PROCEDURE [dbo].[CLIENT_STUDY_CLAIM_WORK_GET]  AS SELECT 1')
GO
ALTER PROCEDURE [dbo].[CLIENT_STUDY_CLAIM_WORK_GET]
	@ID	UNIQUEIDENTIFIER
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

		SELECT TP, DATE, NOTE
		FROM dbo.ClientStudyClaimWork
		WHERE ID = @ID

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [dbo].[CLIENT_STUDY_CLAIM_WORK_GET] TO rl_client_study_claim_apply;
GO
