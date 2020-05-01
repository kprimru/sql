USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [Maintenance].[USERLOG_TIME_REPORT]
	@START	SMALLDATETIME,
	@FINISH	SMALLDATETIME,
	@USR	NVARCHAR(MAX)
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

		SELECT USR, S_DAY, WORK_TIME, dbo.TimeMinToStr(WORK_TIME) AS WORK_TIME_STR
		FROM
			(
				SELECT USR, S_DAY, SUM(WORK_TIME) AS WORK_TIME
				FROM Maintenance.UserlogSessionView
				WHERE (S_DAY >= @START OR @START IS NULL)
					AND (S_DAY <= @FINISH OR @FINISH IS NULL)
					AND (USR IN (SELECT ID FROM dbo.TableStringNewFromXML(@USR)) OR @USR IS NULL)
				GROUP BY USR, S_DAY
			) AS a
		ORDER BY S_DAY DESC, WORK_TIME DESC

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GRANT EXECUTE ON [Maintenance].[USERLOG_TIME_REPORT] TO rl_userlog;
GO