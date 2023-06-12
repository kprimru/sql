USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[dbo].[CLIENT_ORI_GET]', 'P ') IS NULL EXEC('CREATE PROCEDURE [dbo].[CLIENT_ORI_GET]  AS SELECT 1')
GO
ALTER PROCEDURE [dbo].[CLIENT_ORI_GET]
	@CLIENT	INT
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
			CO_NAME, CO_VISIT, CO_INFORMATION,
			CO_RES_NAME, CO_RES_PHONE, CO_RES_POSITION, CO_RES_PLACE,
			CO_STUDY, CO_CLAIM, CO_CURR_STATUS, CO_PLAN_ACTION,
			CO_RESULT, CO_RIVAL, CO_NOTE, CO_DATE, CO_USER
		FROM dbo.ClientOri
		WHERE CO_ID_CLIENT = @CLIENT
			AND CO_STATUS = 1

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [dbo].[CLIENT_ORI_GET] TO rl_client_ori_r;
GO
