USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[CLIENT_AUDIT_GET]
	@ID	INT
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
			CA_ID, CA_DATE,
			CA_STUDY, CA_STUDY_DATE,
			CA_SEARCH, CA_SEARCH_NOTE,
			CA_DUTY, CA_DUTY_DATE, CA_DUTY_AVG,
			CA_TRANSFER, CA_TRANSFER_NOTE,
			CA_RIVAL, CA_RIVAL_DATE, CA_RIVAL_NOTE,
			CA_SYSTEM, CA_SYSTEM_COUNT, CA_SYSTEM_ER_COUNT,
			CA_INCOME, CA_INCOME_NOTE, CA_NOTE, CA_CONTROL,
			CA_CREATE, CA_USER
		FROM dbo.ClientAudit
		WHERE CA_ID = @ID

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [dbo].[CLIENT_AUDIT_GET] TO rl_client_audit_r;
GO