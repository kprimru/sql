USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[CLIENT_DBF_DETAIL_SELECT]
	@ID	INT
WITH EXECUTE AS OWNER
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
			TO_NAME, CL_PSEDO, CL_FULL_NAME, TO_INN, ACTIVITY,
			TA_INDEX, TA_HOME, ADDR_STR, STREET_ID,
			DIR_SURNAME, DIR_NAME, DIR_OTCH, DIR_POS, DIR_PHONE,
			BUH_SURNAME, BUH_NAME, BUH_OTCH, BUH_POS, BUH_PHONE,
			RES_SURNAME, RES_NAME, RES_OTCH, RES_POS, RES_PHONE
		FROM dbo.DBFTODetailView
		WHERE TO_ID = @ID

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GRANT EXECUTE ON [dbo].[CLIENT_DBF_DETAIL_SELECT] TO rl_client_dbf_import;
GO