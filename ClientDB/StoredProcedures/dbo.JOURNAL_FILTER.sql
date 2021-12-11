USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[dbo].[JOURNAL_FILTER]', 'P ') IS NULL EXEC('CREATE PROCEDURE [dbo].[JOURNAL_FILTER]  AS SELECT 1')
GO
ALTER PROCEDURE [dbo].[JOURNAL_FILTER]
	@YEAR		UNIQUEIDENTIFIER,
	@SERVICE	INT
	WITH EXECUTE AS OWNER
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

		DECLARE @BEGIN	SMALLDATETIME

		SELECT @BEGIN = START
		FROM Common.Period
		WHERE ID = @YEAR

		DECLARE @MAIN	UNIQUEIDENTIFIER

		SELECT @MAIN = ID
		FROM dbo.Journal
		WHERE DEF = 1

		IF OBJECT_ID('tempdb..#client') IS NOT NULL
			DROP TABLE #client

		CREATE TABLE #client
			(
				ClientID				INT PRIMARY KEY,
				[СИ]					NVARCHAR(128),
				[Название организации]	NVARCHAR(512),
				[Главная книга]			SMALLINT
			)

		DECLARE @SQL NVARCHAR(MAX)

		SET @SQL = 'ALTER TABLE #client ADD '
		SELECT @SQL = @SQL + '[' + NAME + '] SMALLINT,'
		FROM dbo.Journal
		WHERE DEF <> 1

		SET @SQL = LEFT(@SQL, LEN(@SQL) - 1)

		EXEC (@SQL)

		INSERT INTO #client(ClientID, [Название организации], [СИ])
			SELECT DISTINCT ClientID, ClientFullName, ServiceName
			FROM
				dbo.ClientJournal
				INNER JOIN dbo.ClientView WITH(NOEXPAND) ON ID_CLIENT = ClientID
			WHERE STATUS = 1
				AND (ServiceID = @SERVICE OR @SERVICE IS NULL)
				AND (
						(START >= @BEGIN /*AND ID_JOURNAL = @MAIN*/)
						--OR (START >= DATEADD(YEAR, -1, @BEGIN) AND ID_JOURNAL <> @MAIN)
					)

		UPDATE #client
		SET [Главная книга] =
				(
					SELECT COUNT(DISTINCT ID_JOURNAL)
					FROM dbo.ClientJournal
					WHERE ID_CLIENT = ClientID
						AND STATUS = 1
						AND ID_JOURNAL = @MAIN
						AND START >= @BEGIN
				)

		SET @SQL = 'UPDATE #client
		SET '

		SELECT @SQL = @SQL + '[' + NAME + '] =
				(
					SELECT COUNT(DISTINCT ID_JOURNAL)
					FROM dbo.ClientJournal
					WHERE ID_CLIENT = ClientID
						AND STATUS = 1
						AND ID_JOURNAL = ''' + CONVERT(NVARCHAR(64), ID) + '''
						AND START >= DATEADD(YEAR, -1, ''' + CONVERT(VARCHAR(20), @BEGIN, 112) + ''')
				),'
		FROM dbo.Journal
		WHERE DEF <> 1

		SET @SQL = LEFT(@SQL, LEN(@SQL) - 1)

		EXEC (@SQL)

		SELECT *
		FROM #client
		ORDER BY [СИ], [Название организации]

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
GRANT EXECUTE ON [dbo].[JOURNAL_FILTER] TO rl_journal_report;
GO
