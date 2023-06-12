USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[Mailing].[REQUEST_SEND]', 'P ') IS NULL EXEC('CREATE PROCEDURE [Mailing].[REQUEST_SEND]  AS SELECT 1')
GO
ALTER PROCEDURE [Mailing].[REQUEST_SEND]
	@ID INT
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

		UPDATE Mailing.Requests
		SET SendDate = GetDAte()
		WHERE Id = @ID
			AND SendDate IS NULL

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [Mailing].[REQUEST_SEND] TO rl_mailing_req;
GO
