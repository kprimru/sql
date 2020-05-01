USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [Purchase].[TALK_HISTORY_INSERT]
	@CLIENT	INT,
	@DATE	SMALLDATETIME,
	@WHO	VARCHAR(150),
	@PERS	VARCHAR(150),
	@THEME	VARCHAR(MAX),
	@ID		UNIQUEIDENTIFIER = NULL OUTPUT
AS
BEGIN
	SET NOCOUNT ON

	DECLARE
		@DebugError		VarChar(512),
		@DebugContext	Xml,
		@Params			Xml;

	EXEC [Debug].[Execution@Start]
		@Proc_Id		= @@ProcId,
		@Params			= @Params,
		@DebugContext	= @DebugContext OUT

	BEGIN TRY

		DECLARE @TBL TABLE(ID UNIQUEIDENTIFIER)

		INSERT INTO Purchase.TalkHistory(TH_ID_CLIENT, TH_DATE, TH_WHO, TH_PERSONAL, TH_THEME)
			OUTPUT inserted.TH_ID INTO @TBL
			VALUES(@CLIENT, @DATE, @WHO, @PERS, @THEME)

		SELECT @ID = ID
		FROM @TBL

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GRANT EXECUTE ON [Purchase].[TALK_HISTORY_INSERT] TO rl_talk_history_i;
GO