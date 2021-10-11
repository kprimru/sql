USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [USR].[COMPLECT_JOURNAL_SELECT]
	@UD_COMPLECT	INT
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

		DECLARE @COMPLECT	VARCHAR(50)

		SELECT @COMPLECT = UD_COMPLECT
		FROM USR.USRData
		WHERE UD_ID = @UD_COMPLECT

		SELECT PR_DATE, PR_TEXT, PR_USER, dbo.TimeMilliSecToStr(DATEDIFF(MILLISECOND, PR_BEGIN, PR_END)) AS PR_TIME
		FROM USR.ProcessJournal
		WHERE PR_COMPLECT = @COMPLECT
		ORDER BY PR_DATE DESC

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [USR].[COMPLECT_JOURNAL_SELECT] TO rl_tech_info;
GO
