USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[Report].[HOTLINE_CLIENT_REPORT]', 'P ') IS NULL EXEC('CREATE PROCEDURE [Report].[HOTLINE_CLIENT_REPORT]  AS SELECT 1')
GO
CREATE OR ALTER PROCEDURE [Report].[HOTLINE_CLIENT_REPORT]
	@PARAM	NVARCHAR(MAX) = NULL
WITH EXECUTE AS OWNER
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE
		@DebugError		VarChar(512),
		@DebugContext	Xml,
		@Params			Xml;

	DECLARE @SQL NVARCHAR(MAX)

	DECLARE @Monthes Table
	(
		Start	SmallDateTime	NOT NULL,
		Finish	SmallDateTime	NOT NULL,
		Name	VarCHar(100)	NOT NULL,
		PRIMARY KEY CLUSTERED (Start,Finish)
	);

	EXEC [Debug].[Execution@Start]
		@Proc_Id		= @@ProcId,
		@Params			= @Params,
		@DebugContext	= @DebugContext OUT

	BEGIN TRY

		INSERT INTO @Monthes
		SELECT START, FINISH, CONVERT(VARCHAR(4), DATEPART(YEAR, START)) + '_' + REPLICATE('0', 2 - LEN(CONVERT(VARCHAR(2), DATEPART(MONTH, START)))) + CONVERT(VARCHAR(2), DATEPART(MONTH, START))
		FROM Common.Period
		WHERE [Type] = 2
			AND START < GetDate()
			AND START > DateAdd(Year, -1, GetDate());

        EXEC [Debug].[Execution@Point]
            @DebugContext   = @DebugContext,
            @Name           = 'INSERT INTO @Monthes';

		IF OBJECT_ID('tempdb..#result') IS NOT NULL
			DROP TABLE #result

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

		IF OBJECT_ID('tempdb..#distrs') IS NOT NULL
			DROP TABLE #distrs

		CREATE TABLE #distrs
		(
			HostId		SmallInt,
			Distr		Int,
			Comp		TinyInt,
			MonName		VarChar(100),
			Cnt			SmallInt,
			Reg_Id		Int,
			Client_Id	Int,
			Primary Key Clustered(Distr, HostId, Comp, MonName)
		);

		INSERT INTO #distrs
		SELECT H.HostId, H.Distr, H.Comp, M.Name, Count(*), R.Id, D.ID_CLIENT
		FROM dbo.HotlineChatView	AS H WITH(NOEXPAND)
		INNER JOIN @Monthes			AS M ON M.START <= H.START AND M.FINISH >= H.START
		OUTER APPLY
		(
			SELECT TOP (1) ID_CLIENT
			FROM dbo.ClientDistrView AS D WITH(NOEXPAND)
			WHERE D.HostId = H.HostId
				AND D.DISTR = H.DISTR
				AND D.COMP = H.COMP
		) AS D
		OUTER APPLY
		(
			SELECT TOP (1) ID
			FROM Reg.RegNodeSearchView AS R WITH(NOEXPAND)
			WHERE R.HostId = H.HostId
				AND R.DistrNumber = H.DISTR
				AND R.CompNumber = H.COMP
		) AS R
		GROUP BY H.HostId, H.Distr, H.Comp, M.Name, R.Id, D.ID_CLIENT;

		EXEC [Debug].[Execution@Point]
            @DebugContext   = @DebugContext,
            @Name           = 'INSERT INTO #distrs';

		SET @SQL = 'ALTER TABLE #result ADD '

		SELECT @SQL = @SQL + '[' + MON_NAME + '] BIT,'
		FROM
		(
				SELECT DISTINCT MON = START, MON_NAME = Name
				FROM @Monthes
		) AS a
		ORDER BY MON

		SET @SQL = LEFT(@SQL, LEN(@SQL) - 1)

		EXEC (@SQL)

		INSERT INTO #result(TP, ManagerName, ServiceName, ClientFullName, ClientID, DistrStr, NT_SHORT, HotlineEnable, HotlineDate)
		SELECT
			1, ManagerName, ServiceName, ClientFullName, ClientID, D.DistrStr, D.DistrTypeName,
			CASE WHEN [HotlineDate] IS NOT NULL THEN 1 ELSE 0 END, [HotlineDate]
		FROM dbo.ClientView							AS C WITH(NOEXPAND)
		INNER JOIN [dbo].[ServiceStatusConnected]() AS S ON C.ServiceStatusId = S.ServiceStatusId
		OUTER APPLY
		(
			SELECT TOP 1 DistrStr, DistrTypeName
			FROM dbo.ClientDistrView AS CD WITH(NOEXPAND)
			WHERE CD.ID_CLIENT = ClientID AND DS_REG = 0
			ORDER BY SystemOrder, DISTR, COMP
		) AS D
		OUTER APPLY
		(
			SELECT [HotlineDate] = MAX(dbo.DateOf(SET_DATE))
			FROM
				dbo.ClientDistrView			AS CD WITH(NOEXPAND)
				INNER JOIN dbo.HotlineDistr AS HD ON ID_HOST = HostID AND CD.DISTR = HD.DISTR AND CD.COMP = HD.COMP
			WHERE CD.ID_CLIENT = ClientID AND HD.STATUS = 1
		) AS H

		UNION ALL

		SELECT
			2, SubhostName, SubhostName, Comment, R.ID, DistrStr, NT_SHORT,
			CASE WHEN [HotlineDate] IS NOT NULL THEN 1 ELSE 0 END, [HotlineDate]
		FROM Reg.RegNodeSearchView AS R WITH(NOEXPAND)
		INNER JOIN
		(
			SELECT DISTINCT MainHostID, MainCompNumber, MainDistrNumber
			FROM dbo.RegNodeMainDistrView WITH(NOEXPAND)
		) AS RM ON R.HostID = RM.MainHostID
				AND R.DistrNumber = RM.MainDistrNumber
				AND R.CompNumber = RM.MainCompNumber
		OUTER APPLY
		(
			SELECT [HotlineDate] = MAX(dbo.DateOf(SET_DATE))
			FROM dbo.HotlineDistr HD
			WHERE ID_HOST = HostID
					AND R.DistrNumber = HD.DISTR
					AND R.CompNumber = HD.COMP
					AND HD.STATUS = 1
		) AS H
		WHERE DS_REG = 0
			AND NOT EXISTS
				(
					SELECT *
					FROM dbo.ClientDistrView AS CD WITH(NOEXPAND)
					WHERE CD.HostID = R.HostID
						AND CD.DISTR = R.DistrNumber
						AND CD.COMP = R.CompNumber
				)

        EXEC [Debug].[Execution@Point]
            @DebugContext   = @DebugContext,
            @Name           = 'INSERT INTO #result';

		SET @SQL = ''
		SELECT @SQL = @SQL + '
		UPDATE #result
		SET [' + CONVERT(VARCHAR(4), DATEPART(YEAR, START)) + '_' + REPLICATE('0', 2 - LEN(CONVERT(VARCHAR(2), DATEPART(MONTH, START)))) + CONVERT(VARCHAR(2), DATEPART(MONTH, START)) + '] =
			CASE TP
				WHEN 1 THEN
					(
						SELECT COUNT(*)
						FROM #distrs
						WHERE ClientID = Client_Id AND MonName = ''' + M.Name + '''
					)
				WHEN 2 THEN
					(
						SELECT COUNT(*)
						FROM #distrs
						WHERE ClientID = Reg_Id AND MonName = ''' + M.Name + '''
					)
			END
		'
		FROM
		(
			SELECT START, FINISH, Name
			FROM @Monthes
		) AS M

		EXEC (@SQL)

        EXEC [Debug].[Execution@Point]
            @DebugContext   = @DebugContext,
            @Name           = 'UPDATE #result';

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

		IF OBJECT_ID('tempdb..#distrs') IS NOT NULL
			DROP TABLE #distrs

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [Report].[HOTLINE_CLIENT_REPORT] TO rl_report;
GO
