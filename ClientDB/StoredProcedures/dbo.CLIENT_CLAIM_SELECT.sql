USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[dbo].[CLIENT_CLAIM_SELECT]', 'P ') IS NULL EXEC('CREATE PROCEDURE [dbo].[CLIENT_CLAIM_SELECT]  AS SELECT 1')
GO
CREATE OR ALTER PROCEDURE [dbo].[CLIENT_CLAIM_SELECT]
	@CL_ID	INT
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

		SELECT CLM_ID, CLM_ID_CLAIM, CLM_ID_CLIENT, CLM_DATE, CLM_AUTHOR, CLM_STATUS, CLM_TYPE, CLM_ACTION_BEFORE, CLM_PROBLEM, CLM_AFTER, CLM_EX_DATE, CLM_REAL_TYPE, CLM_EXECUTOR, CLM_COMMENT, CLM_EXECUTE_ACTION
		FROM dbo.ClaimTable
		WHERE CLM_ID_CLIENT = @CL_ID
		ORDER BY CLM_DATE DESC

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [dbo].[CLIENT_CLAIM_SELECT] TO rl_client_tech_r;
GO
