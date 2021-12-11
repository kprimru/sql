USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[dbo].[CLIENT_RIVAL_GET]', 'P ') IS NULL EXEC('CREATE PROCEDURE [dbo].[CLIENT_RIVAL_GET]  AS SELECT 1')
GO
ALTER PROCEDURE [dbo].[CLIENT_RIVAL_GET]
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

		SELECT CR_DATE, CR_ID_TYPE, CR_CONDITION, CR_ID_STATUS, CR_SURNAME, CR_NAME, CR_PATRON, CR_PHONE
		FROM dbo.ClientRival
		WHERE CR_ID = @ID

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [dbo].[CLIENT_RIVAL_GET] TO rl_client_rival_r;
GO
