USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [Purchase].[TALK_HISTORY_DELETE]
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

		INSERT INTO Purchase.TalkHistory(TH_ID_MASTER, TH_ID_CLIENT, TH_DATE, TH_WHO, TH_PERSONAL, TH_THEME, TH_STATUS, TH_UPDATE, TH_USER)
			SELECT @ID, TH_ID_CLIENT, TH_DATE, TH_WHO, TH_PERSONAL, TH_THEME, 2, TH_UPDATE, TH_USER
			FROM Purchase.TalkHistory
			WHERE TH_ID = @ID

		UPDATE Purchase.TalkHistory
		SET TH_STATUS = 3,
			TH_UPDATE = GETDATE(),
			TH_USER = ORIGINAL_LOGIN()
		WHERE TH_ID = @ID

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GRANT EXECUTE ON [Purchase].[TALK_HISTORY_DELETE] TO rl_talk_history_d;
GO