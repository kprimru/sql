USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[Purchase].[TALK_HISTORY_SELECT]', 'P ') IS NULL EXEC('CREATE PROCEDURE [Purchase].[TALK_HISTORY_SELECT]  AS SELECT 1')
GO
ALTER PROCEDURE [Purchase].[TALK_HISTORY_SELECT]
	@CLIENT		INT,
	@TEXT		VARCHAR(150),
	@DELETED	BIT
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

		SELECT
			TH_ID, TH_DATE, TH_WHO, TH_PERSONAL, TH_THEME, TH_STATUS,
			CONVERT(VARCHAR(20), TH_UPDATE, 104) + ' ' + CONVERT(VARCHAR(20), TH_UPDATE, 108) + ' / ' + TH_USER AS TH_UPDATE_DATA
		FROM Purchase.TalkHistory
		WHERE TH_ID_CLIENT = @CLIENT
			AND (TH_STATUS = 1 OR TH_STATUS = 3 AND @DELETED = 1)
			AND (TH_THEME LIKE @TEXT OR @TEXT IS NULL)
		ORDER BY TH_DATE DESC

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [Purchase].[TALK_HISTORY_SELECT] TO rl_talk_history_r;
GO
