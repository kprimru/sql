USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [Report].[HOTLINE_CLIENT_REPORT]
	@PARAM	NVARCHAR(MAX) = NULL
WITH EXECUTE AS OWNER
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE
		@DebugError		VarChar(512),
		@DebugContext	Xml,
		@Params			Xml;

	DECLARE @Monthes Table
	(
		Start	SmallDateTime	NOT NULL,
		Finish	SmallDateTime	NOT NULL,
		PRIMARY KEY CLUSTERED (Start,Finish)
	);

	EXEC [Debug].[Execution@Start]
		@Proc_Id		= @@ProcId,
		@Params			= @Params,
		@DebugContext	= @DebugContext OUT

	BEGIN TRY

		INSERT INTO @Monthes
		SELECT START, FINISH
		FROM Common.Period
		WHERE [Type] = 2
			AND START < GetDate()
			AND START > DateAdd(Year, -1, GetDate());

		CREATE TABLE #result
		(
			TP				TINYINT,
			ManagerName		VARCHAR(150),
			ServiceName		VARCHAR(150),
			ClientFullName	VARCHAR(500),
			ClientID		INT,
			DistrStr		NVARCHAR(64),
			NT_SHORT		NVARCHAR(64),
			HotlineEnable	BIT,
			HotlineDate		SMALLDATETIME,
			PRIMARY KEY CLUSTERED(TP, ClientID)
		);

		DECLARE @SQL NVARCHAR(MAX)

		SET @SQL = 'ALTER TABLE #result ADD '

		SELECT @SQL = @SQL + '[' + CONVERT(VARCHAR(4), DATEPART(YEAR, MON)) + '_' + REPLICATE('0', 2 - LEN(CONVERT(VARCHAR(2), DATEPART(MONTH, MON)))) + CONVERT(VARCHAR(2), DATEPART(MONTH, MON)) + '] BIT,'
		FROM
			(
				SELECT DISTINCT MON = START
				FROM @Monthes
			) AS a
		ORDER BY MON

		SET @SQL = LEFT(@SQL, LEN(@SQL) - 1)

		EXEC (@SQL)

		INSERT INTO #result(TP, ManagerName, ServiceName, ClientFullName, ClientID, DistrStr, NT_SHORT, HotlineEnable, HotlineDate)
		SELECT
			1, ManagerName, ServiceName, ClientFullName, ClientID,
			(
				SELECT TOP 1 DistrStr
				FROM dbo.ClientDistrView b WITH(NOEXPAND)
				WHERE b.ID_CLIENT = ClientID AND DS_REG = 0
				ORDER BY SystemOrder, DISTR, COMP
			),
			(
				SELECT TOP 1 DistrTypeName
				FROM dbo.ClientDistrView b WITH(NOEXPAND)
				WHERE b.ID_CLIENT = ClientID AND DS_REG = 0
				ORDER BY SystemOrder, DISTR, COMP
			),
			--ToDO сделать через OUTER APPLY без дублирования
			CASE WHEN EXISTS
				(
					SELECT *
					FROM
						dbo.ClientDistrView b WITH(NOEXPAND)
						INNER JOIN dbo.HotlineDistr c ON ID_HOST = HostID AND b.DISTR = c.DISTR AND b.COMP = c.COMP
					WHERE b.ID_CLIENT = ClientID AND c.STATUS = 1
				) THEN 1
				ELSE 0
			END,
			(
				SELECT MAX(dbo.DateOf(SET_DATE))
				FROM
					dbo.ClientDistrView b WITH(NOEXPAND)
					INNER JOIN dbo.HotlineDistr c ON ID_HOST = HostID AND b.DISTR = c.DISTR AND b.COMP = c.COMP
					WHERE b.ID_CLIENT = ClientID AND c.STATUS = 1
				)
			FROM dbo.ClientView a WITH(NOEXPAND)
			INNER JOIN [dbo].[ServiceStatusConnected]() s ON a.ServiceStatusId = s.ServiceStatusId

			UNION ALL

			SELECT
				2, SubhostName, SubhostName, Comment, a.ID, DistrStr, NT_SHORT,
				CASE WHEN EXISTS
					(
						SELECT *
						FROM dbo.HotlineDistr c
						WHERE ID_HOST = HostID
							AND a.DistrNumber = c.DISTR
							AND a.CompNumber = c.COMP
							AND c.STATUS = 1
					) THEN 1
					ELSE 0
				END,
				(
					SELECT MAX(dbo.DateOf(SET_DATE))
					FROM dbo.HotlineDistr c
					WHERE ID_HOST = HostID
							AND a.DistrNumber = c.DISTR
							AND a.CompNumber = c.COMP
							AND c.STATUS = 1
				)
			FROM
				Reg.RegNodeSearchView a WITH(NOEXPAND)
				INNER JOIN
					(
						SELECT DISTINCT MainHostID, MainCompNumber, MainDistrNumber
						FROM dbo.RegNodeMainDistrView WITH(NOEXPAND)
					) AS b ON a.HostID = b.MainHostID
						AND a.DistrNumber = b.MainDistrNumber
						AND a.CompNumber = b.MainCompNumber
			WHERE DS_REG = 0
				AND NOT EXISTS
					(
						SELECT *
						FROM dbo.ClientDistrView z WITH(NOEXPAND)
						WHERE z.HostID = a.HostID
							AND z.DISTR = a.DistrNumber
							AND z.COMP = a.CompNumber
					)

		--ToDO тут полные сканы чатов. Плохо
		-- наверное, надо подготовитть данные в виде Дистрибутив, месяц, количество и потом с этим работать
		SET @SQL = ''
		SELECT @SQL = @SQL + '
		UPDATE #result
		SET [' + CONVERT(VARCHAR(4), DATEPART(YEAR, START)) + '_' + REPLICATE('0', 2 - LEN(CONVERT(VARCHAR(2), DATEPART(MONTH, START)))) + CONVERT(VARCHAR(2), DATEPART(MONTH, START)) + '] =
			CASE TP
				WHEN 1 THEN
					(
						SELECT COUNT(*)
						FROM dbo.HotlineChatView A WITH(NOEXPAND)
						INNER JOIN dbo.ClientDistrView b WITH(NOEXPAND) ON a.HostId = b.HostID
																		AND a.DISTR = b.DISTR
																		AND a.COMP = b.COMP
						WHERE ClientID = ID_CLIENT AND START >= ''' + CONVERT(VARCHAR(20), a.START, 112) + ''' AND START <= ''' + CONVERT(VARCHAR(20), a.FINISH, 112) + '''
					)
				WHEN 2 THEN
					(
						SELECT COUNT(*)
						FROM dbo.HotlineChatView A WITH(NOEXPAND)
						INNER JOIN Reg.RegNodeSearchView b WITH(NOEXPAND) ON a.HostId = b.HostID
																		AND a.DISTR = b.DistrNumber
																		AND a.COMP = b.CompNumber
						WHERE ClientID = B.ID AND START >= ''' + CONVERT(VARCHAR(20), a.START, 112) + ''' AND START <= ''' + CONVERT(VARCHAR(20), a.FINISH, 112) + '''
					)
			END
		'
		FROM
		(
			SELECT START, FINISH
			FROM @Monthes
		) AS a

		EXEC (@SQL)

		SET @SQL = 'SELECT ManagerName AS [Рук-ль], ServiceName AS [СИ], ClientFullName AS [Клиент], DistrStr AS [Дистрибутив], NT_SHORT AS [Сеть], HotlineEnable AS [Кнопка включена], HotlineDate AS [Дата подключения],'
		SELECT @SQL = @SQL + '[' + CONVERT(VARCHAR(4), DATEPART(YEAR, MON)) + '_' + REPLICATE('0', 2 - LEN(CONVERT(VARCHAR(2), DATEPART(MONTH, MON)))) + CONVERT(VARCHAR(2), DATEPART(MONTH, MON)) + '],'
		FROM
			(
				SELECT DISTINCT MON = START
				FROM @Monthes
			) AS a
		ORDER BY MON

		SET @SQL = LEFT(@SQL, LEN(@SQL) - 1) + ' FROM #result ORDER BY TP DESC, ManagerName, ServiceName, ClientFullName'

		EXEC (@SQL)

		IF OBJECT_ID('tempdb..#result') IS NOT NULL
			DROP TABLE #result

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GRANT EXECUTE ON [Report].[HOTLINE_CLIENT_REPORT] TO rl_report;
GO