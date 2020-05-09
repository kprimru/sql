USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[CLIENT_STT_SELECT]
	@CLIENT	INT
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

		IF OBJECT_ID('tempdb..#stt') IS NOT NULL
			DROP TABLE #stt

		CREATE TABLE #stt
			(
				ID		UNIQUEIDENTIFIER PRIMARY KEY DEFAULT NEWSEQUENTIALID(),
				FL_NAME	NVARCHAR(256),
				FL_SIZE	NVARCHAR(128),
				FL_DATE	DATETIME,
				DATE	DATETIME,
				RN		INT
			)


		INSERT INTO #stt(FL_NAME, FL_SIZE, FL_DATE, DATE, RN)
			SELECT FL_NAME, dbo.FileByteSizeToStr(FL_SIZE), FL_DATE, DATE, ROW_NUMBER() OVER(PARTITION BY FL_NAME ORDER BY DATE DESC)
			FROM
				dbo.ClientStat a
				INNER JOIN dbo.SystemTable b ON a.SYS_NUM = b.SystemNumber
				INNER JOIN dbo.ClientDistrView c WITH(NOEXPAND) ON c.HostID = b.HostID AND c.DISTR = a.DISTR AND c.COMP = a.COMP
			WHERE c.ID_CLIENT = @CLIENT

		SELECT ID, NULL AS ID_MASTER, FL_NAME, FL_SIZE, FL_DATE, DATE
		FROM #stt
		WHERE RN = 1

		UNION ALL

		SELECT NEWID(), (SELECT ID FROM #stt z WHERE z.FL_NAME = a.FL_NAME AND z.RN = 1), FL_NAME, FL_SIZE, FL_DATE, DATE
		FROM #stt a
		WHERE RN <> 1

		ORDER BY DATE DESC

		IF OBJECT_ID('tempdb..#stt') IS NOT NULL
			DROP TABLE #stt

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [dbo].[CLIENT_STT_SELECT] TO rl_client_stat_report;
GO