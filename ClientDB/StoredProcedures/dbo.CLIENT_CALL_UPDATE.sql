USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[CLIENT_CALL_UPDATE]
	@ID			UNIQUEIDENTIFIER,
	@CLIENT		INT,
	@DATE		SMALLDATETIME,
	@PERSONAL	VARCHAR(250),
	@SERVICE	VARCHAR(150),
	@NOTE		VARCHAR(MAX)
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

		UPDATE dbo.ClientCall
		SET CC_DATE		=	@DATE,
			CC_PERSONAL	=	@PERSONAL,
			CC_SERVICE	=	@SERVICE,
			CC_NOTE		=	@NOTE
		WHERE CC_ID = @ID

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [dbo].[CLIENT_CALL_UPDATE] TO rl_client_call_u;
GO
