USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[Seminar].[WEB_MAIL_INVITE_SET]', 'P ') IS NULL EXEC('CREATE PROCEDURE [Seminar].[WEB_MAIL_INVITE_SET]  AS SELECT 1')
GO
ALTER PROCEDURE [Seminar].[WEB_MAIL_INVITE_SET]
	@ID		UNIQUEIDENTIFIER,
	@BIN	VARBINARY(MAX)
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

		INSERT INTO Seminar.Invite(ID_PERSONAL, BIN)
			SELECT @ID, @BIN

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [Seminar].[WEB_MAIL_INVITE_SET] TO rl_seminar_web;
GO
