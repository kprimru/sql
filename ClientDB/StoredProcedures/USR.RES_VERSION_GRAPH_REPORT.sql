USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [USR].[RES_VERSION_GRAPH_REPORT]
	@BEGIN	SMALLDATETIME,
	@END	SMALLDATETIME,
	@MANAGER	INT,
	@SERVICE	INT
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

		DECLARE @WEEK TABLE
			(
				WEEK_ID	INT,
				WBEGIN SMALLDATETIME,
				WEND SMALLDATETIME
			)

		INSERT INTO @WEEK
			SELECT *
			FROM dbo.WeekDates(@BEGIN, @END)

		IF OBJECT_ID('tempdb..#client') IS NOT NULL
			DROP TABLE #client

		CREATE TABLE #client
			(
				CL_ID	INT	PRIMARY KEY
			)

		INSERT INTO #client(CL_ID)
			SELECT ClientID
			FROM
				dbo.ClientView WITH(NOEXPAND)
			WHERE (ServiceID = @SERVICE OR @SERVICE IS NULL)
				AND (ManagerID = @MANAGER OR @MANAGER IS NULL)

		SELECT
			WEEK_ID, WBEGIN, WEND, COUNT(*) AS RES_COUNT
		FROM
			@WEEK
			INNER JOIN USR.USRVersionView ON UF_DATE BETWEEN WBEGIN AND WEND
			INNER JOIN #client ON UD_ID_CLIENT = CL_ID
		GROUP BY WEEK_ID, WBEGIN, WEND
		ORDER BY WEEK_ID

		IF OBJECT_ID('tempdb..#client') IS NOT NULL
			DROP TABLE #client

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [USR].[RES_VERSION_GRAPH_REPORT] TO rl_report_res_version_graph;
GRANT EXECUTE ON [USR].[RES_VERSION_GRAPH_REPORT] TO rl_report_unservice_complect_graph;
GO