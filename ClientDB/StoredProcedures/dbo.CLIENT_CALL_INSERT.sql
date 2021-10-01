USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[CLIENT_CALL_INSERT]
	@CLIENT		INT,
	@DATE		SMALLDATETIME,
	@PERSONAL	VARCHAR(250),
	@SERVICE	VARCHAR(150),
	@NOTE		VARCHAR(MAX),
	@ID			UNIQUEIDENTIFIER = NULL OUTPUT
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

		DECLARE @TBL TABLE (ID UNIQUEIDENTIFIER)

		INSERT INTO dbo.ClientCall(CC_ID_CLIENT, CC_DATE, CC_PERSONAL, CC_SERVICE, CC_NOTE)
			OUTPUT INSERTED.CC_ID INTO @TBL
			VALUES(@CLIENT, @DATE, @PERSONAL, @SERVICE, @NOTE)

		SELECT @ID = ID FROM @TBL

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [dbo].[CLIENT_CALL_INSERT] TO rl_client_call_i;
GO
