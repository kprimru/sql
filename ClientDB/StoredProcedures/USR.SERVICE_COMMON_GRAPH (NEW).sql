USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [USR].[SERVICE_COMMON_GRAPH (NEW)]
	@Service	Int,
	@Start		SmallDateTime,
	@Finish		SmallDateTime,
	@Types		VarChar(MAX)	= NULL
AS
BEGIN
	SET NOCOUNT ON;
	
	DECLARE @SQL NVARCHAR(MAX);
	
	DECLARE
		@MonthStart		SmallDateTime,
		@MonthFinish	SmallDateTime;
	
	DECLARE @Weeks TABLE
	(
		Id		Int,
		Start	SmallDateTime, 
		Finish	SmallDateTime,
		PRIMARY KEY CLUSTERED(Id)
	);

	INSERT INTO @Weeks
	SELECT WEEK_ID, WBEGIN, WEND
	FROM dbo.WeekDates(@Start, @Finish);
	
	-- вычисляем начало и окончания месяца (по дата окончания)
	SET @MonthStart		= Cast(Convert(Char(6), @Finish, 112) + '01' AS SmallDateTime);
	SET @MonthFinish	= Cast(Convert(Char(6), DateAdd(Month, 1, @Finish), 112) + '01' AS SmallDateTime);

	DECLARE @Clients TABLE
	(
		ClientId			Int,
		Complect			VarChar(100),
		--
		ResVersion			SmallInt,
		ConsExeVersion		SmallInt,
		--
		TypeDailyDays		TinyInt,
		TypeDays			TinyInt,
		DayOrder			SmallInt,			
		ServiceDay			VarChar(50),
		DayTime				DateTime,
		--
		DistrTypeBaseCheck	Bit,
		PRIMARY KEY CLUSTERED (ClientId, Complect)
	);

	DECLARE @ClientsDistrs TABLE
	(
		ClientId		Int,
		Complect		VarChar(100),
		SystemId		SmallInt,
		Distr			Int,
		Comp			TinyInt,
		--
		SystemBaseName	VarCHar(100),
		Primary Key Clustered (ClientId, Complect, Distr, Comp, SystemId)
	);

	INSERT INTO @Clients(ClientId, Complect, TypeDailyDays, TypeDays, DayOrder, ServiceDay, DayTime, DistrTypeBaseCheck)
	SELECT 
		c.ClientID, Complect, ClientTypeDailyDay, ClientTypeDay, DayOrder,
		ISNULL(d.DayShort, '') + ' ' + ISNULL(LEFT(CONVERT(VARCHAR(20), ServiceStart, 108), 5), ''), ServiceStart,
		0
	FROM dbo.ClientTable c
	INNER JOIN
	(
		SELECT Item 
		FROM dbo.GET_TABLE_FROM_LIST(@Types, ',')
	) AS s ON c.ServiceTypeID = s.Item
	CROSS APPLY
	(
		SELECT Complect
		FROM dbo.RegNodeComplectClientView t
		WHERE c.ClientID = t.ClientId
			AND DS_REG = 0
	) t
	LEFT JOIN dbo.ClientTypeAllView r ON r.ClientID = c.ClientId
	LEFT JOIN dbo.ClientTypeTable	b ON r.CATEGORY = b.ClientTypeName
	LEFT JOIN dbo.DayTable			d ON c.DayID = d.DayID
	WHERE	c.ClientServiceID  = @SERVICE 
		-- ToDo заменить на именованное множество
		AND c.StatusID = 2
		AND c.STATUS = 1;

	INSERT INTO @ClientsDistrs(ClientId, Complect, SystemId, Distr, Comp, SystemBaseName)
	SELECT C.ClientId, C.Complect, D.SystemId, D.DISTR, D.COMP, D.SystemBaseName
	FROM @Clients C
	INNER JOIN dbo.ClientDistrView D ON C.ClientID = D.ID_CLIENT
	-- ToDo заменить на именованное множество
	WHERE	D.DS_REG = 0
		AND D.SystemBaseCheck = 1
		AND D.DistrTypeBaseCheck = 1;

	-- по каждому комплекту находим тех модуль и cons.exe
	UPDATE C
	SET ResVersion		= t.UF_ID_RES,
		ConsExeVersion	= T.UF_ID_CONS
	FROM @Clients C
	INNER JOIN USR.USRActiveView z ON z.UD_ID_CLIENT = C.ClientId
	INNER JOIN USR.USRFileTech t ON z.UF_ID = t.UF_ID
	INNER JOIN dbo.SystemTable y ON z.UF_ID_SYSTEM = y.SystemID 
	INNER JOIN dbo.RegNodeTable x ON x.SystemName = SystemBaseName AND z.UD_DISTR = x.DistrNumber AND z.UD_COMP = x.CompNumber
	WHERE	x.Service = 0
		AND x.Complect = c.Complect;

	UPDATE C
	SET DistrTypeBaseCheck = 1
	FROM @Clients C
	INNER JOIN @ClientsDistrs D ON C.ClientId = D.ClientId;

	DECLARE @Result Table
	(
		ClientID				Int,
		Complect				VarChar(100),
		TypeDailyDays			TinyInt,
		TypeDays				TinyInt,
		DayOrder				SmallInt,			
		ServiceDay				VarChar(50),
		DayTime					DateTime,
		ResVersion				VARCHAR(150),
		ConsExe					VARCHAR(150),
		ConsExeActual			INT,
		ResActual				INT,
		ClientEvent				VARCHAR(MAX),
		DistrTypeBaseCheck		TINYINT,
		LastSTT					VARCHAR(20),
		PRIMARY KEY CLUSTERED(ClientID, Complect)
	);
		
	/* формируем костяк для итоговой таблицы.*/
	INSERT INTO #res(
			ID, ClientID, ClientFullName, SystemList, ClientTypeName, TypeDailyDays, TypeDays, ServiceType, 
			DayOrder, ServiceDay, DayTime, ResVersion, ConsExe, ConsExeActual, ResActual, ClientEvent, DistrTypeBaseCheck, LastSTT)
		SELECT 
			ROW_NUMBER() OVER(ORDER BY ClientFullName),
			a.ClientID, ClientFullName, 
			REVERSE(STUFF(REVERSE(
				(
					SELECT
						SystemShortName + 
							CASE
								WHEN RN = 1 THEN ' (' + CONVERT(VARCHAR(20), SystemDistrNumber) + CASE CompNumber WHEN 1 THEN '' ELSE '/' + CONVERT(VARCHAR(20), CompNumber) END + ')'
								ELSE ''
							END + ', '
					FROM 
						(
							SELECT 
								ROW_NUMBER() OVER(ORDER BY SystemOrder, DISTR, COMP) AS RN, 
								SystemShortName, DISTR AS SystemDistrNumber, COMP AS CompNumber, SystemOrder
							FROM
								dbo.ClientDistrView y WITH(NOEXPAND) 
							WHERE DS_REG = 0 AND y.ID_CLIENT = a.ClientID
						) AS t
					ORDER BY SystemOrder FOR XML PATH('')
				)
			), 1, 2, '')),
			ClientTypeName, ClientTypeDailyDay, 
			ClientTypeDay, ServiceTypeShortName, DayOrder,
			ISNULL(c.DayShort, '') + ' ' + ISNULL(LEFT(CONVERT(VARCHAR(20), ServiceStart, 108), 5), ''), ServiceStart,
			/* вписываем через запятую все технологические модули, версии cons.exe для
			 активных комплектов, в которых основная система сопровождается.
			 а также вычисляем, если есть устаревшие модули или cons.exe - выводим признак
			*/
			(
				REVERSE(STUFF(REVERSE((
					SELECT DISTINCT ResVersionShort + ', '
					FROM 
						@Clients z INNER JOIN
						dbo.ResVersionTable ON ResVersionID = ResVersion 
					WHERE z.ClientID = a.ClientID
					FOR XML PATH(''))
				), 1, 2, '')) 				
			),
			(
				REVERSE(STUFF(REVERSE((
					SELECT DISTINCT ConsExeVersionName + ', '
					FROM 
						@Clients z INNER JOIN
						dbo.ConsExeVersionTable ON ConsExeVersionID = ConsExeVersion
					WHERE z.ClientID = a.ClientID
					FOR XML PATH(''))
				), 1, 2, '')) 				
			),
			CASE 
				WHEN NOT EXISTS
					(
						SELECT *
						FROM 
							@Clients z INNER JOIN
							dbo.ConsExeVersionTable ON ConsExeVersionID = ConsExeVersion
						WHERE z.ClientID = a.ClientID
							AND ConsExeVersionActive = 0
					) THEN 1
				ELSE 0
			END,
			CASE 
				WHEN NOT EXISTS
					(
						SELECT *
						FROM 
							@Clients z INNER JOIN
							dbo.ResVersionTable ON ResVersionID = ResVersion 
						WHERE z.ClientID = a.ClientID
							AND IsLatest = 0
					) THEN 1
				ELSE 0
			END,
			REVERSE(STUFF(REVERSE((
				SELECT 
					CONVERT(VARCHAR(20), EventDate, 104) + '    ' + 
					EventComment + CHAR(10) + CHAR(10)
				FROM
					dbo.EventTable z INNER JOIN
					dbo.EventTypeTable y ON z.EventTypeID = y.EventTypeID
				WHERE z.ClientID = a.ClientID
					AND EventDate >= @Start AND EventDate <= @Finish
					AND EventActive = 1
					AND EventTypeName NOT IN ('КГС 223', 'КГС 94') 
				ORDER BY EventDate FOR XML PATH('')
			)), 1, 2, '')),
			(
				SELECT MAX(CONVERT(TINYINT, DistrTypeBaseCheck))
				FROM dbo.ClientDistrView z WITH(NOEXPAND)
				WHERE z.ID_CLIENT = a.ClientID
					AND DS_REG = 0
			),			
			ISNULL(CONVERT(VARCHAR(20), dbo.DateOf(
				(
					SELECT MAX(DATE)
					FROM 
						dbo.ClientStat z
						INNER JOIN dbo.ClientDistrView y WITH(NOEXPAND) ON z.DISTR = y.DISTR AND z.COMP = y.COMP 
						INNER JOIN dbo.SystemTable x ON x.HostID = y.HostID AND x.SystemNumber = z.SYS_NUM
					WHERE y.ID_CLIENT = a.ClientID
						AND DATE >= @MonthStart AND DATE < @MonthFinish
				)), 104) + '',
				CONVERT(VARCHAR(20), dbo.DateOf(
				(
					SELECT MAX(DATE)
					FROM 
						#ip z
						INNER JOIN dbo.ClientDistrView y WITH(NOEXPAND) ON z.DISTR = y.DISTR AND z.COMP = y.COMP 
						INNER JOIN dbo.SystemTable x ON x.SystemID = y.SystemID AND x.SystemNumber = z.SYS
					WHERE y.ID_CLIENT = a.ClientID
				)), 104) + ' (И)')
		FROM dbo.ClientTable a
		CROSS APPLY
		(
			SELECT Complect
			FROM dbo.RegNodeComplectClientView t
			WHERE a.ClientID = t.ClientId
				AND DS_REG = 0
		) t
		INNER JOIN dbo.ServiceTypeTable d ON d.ServiceTypeID = a.ServiceTypeID
		INNER JOIN
		(
			SELECT Item 
			FROM dbo.GET_TABLE_FROM_LIST(@Types, ',')
		) AS o_O ON d.ServiceTypeID = Item
		LEFT JOIN dbo.ClientTypeAllView r ON r.ClientID = a.ClientID
		LEFT JOIN dbo.ClientTypeTable b ON r.CATEGORY = b.ClientTypeName
		LEFT JOIN dbo.DayTable c ON a.DayID = c.DayID
		WHERE ClientServiceID  = @SERVICE AND StatusID = 2 AND STATUS = 1
		ORDER BY ClientFullName;
		
	IF OBJECT_ID('tempdb..#update') IS NOT NULL
		DROP TABLE #update

	CREATE TABLE #update
		(
			ClientID			INT,
			UF_PATH				TINYINT,		
			UpdateDateTime		DATETIME,
			WD					CHAR(2)
		)	

	IF OBJECT_ID('tempdb..#usrdata') IS NOT NULL
		DROP TABLE #usrdata

	CREATE TABLE #usrdata
		(
			ID					INT IDENTITY(1, 1),
			UD_ID_CLIENT		INT,
			UF_PATH				TINYINT,
			UI_DISTR			INT,
			UI_COMP				TINYINT,
			UIU_DATE			SMALLDATETIME,
			UIU_DATE_S			SMALLDATETIME,
			UIU_DOCS			INT,
			InfoBankID			INT			
		)

	INSERT INTO #usrdata(UD_ID_CLIENT, UF_PATH, UI_DISTR, UI_COMP, UIU_DATE, UIU_DATE_S, UIU_DOCS, InfoBankID)
		SELECT DISTINCT UD_ID_CLIENT, UF_PATH, UI_DISTR, UI_COMP, UIU_DATE, UIU_DATE_S, UIU_DOCS, UI_ID_BASE
		FROM
			#client
			INNER JOIN USR.USRIBDateView WITH(NOEXPAND) ON UD_ID_CLIENT = CL_ID
		WHERE UIU_DATE_S >= @Start AND UIU_DATE_S <= @Finish

	SET @SQL = N'CREATE CLUSTERED INDEX [IX_' + CONVERT(VARCHAR(50), NEWID()) + '] ON #usrdata (UD_ID_CLIENT, UIU_DATE, UIU_DATE_S)'

	EXEC (@SQL)

	SET @SQL = N'CREATE STATISTICS [ST_' + CONVERT(VARCHAR(50), NEWID()) + '] ON #usrdata (UIU_DATE) WITH FULLSCAN'

	EXEC (@SQL)
	
	INSERT INTO #update(ClientID, UF_PATH, UpdateDateTime, WD)
		SELECT 
			UD_ID_CLIENT, 1,
			CONVERT(DATETIME, LEFT(CONVERT(VARCHAR(50), c.UIU_DATE_S, 121), 10) + ' ' +
				(
					SELECT MIN(LEFT(CONVERT(VARCHAR(20), t.UIU_DATE, 114), 5))
					FROM #usrdata t
					WHERE t.UD_ID_CLIENT = c.UD_ID_CLIENT
						AND t.UIU_DATE_S = c.UIU_DATE_S
				) + ':00', 121),
			DayShort
		FROM 
			(
				SELECT DISTINCT UD_ID_CLIENT, UF_PATH, UIU_DATE_S
				FROM 
					#usrdata d
			) AS c
			INNER JOIN dbo.DayTable ON DayOrder = DATEPART(WEEKDAY, UIU_DATE_S)
		
	INSERT INTO #update(ClientID, UF_PATH, UpdateDateTime, WD)
		SELECT 
			UD_ID_CLIENT, UF_PATH,
			UF_DATE,
			DayShort
		FROM 
			#client
			INNER JOIN USR.USRData ON UD_ID_CLIENT = CL_ID
			INNER JOIN USR.USRFile ON UF_ID_COMPLECT = UD_ID
			INNER JOIN dbo.DayTable ON DayOrder = DATEPART(WEEKDAY, UF_DATE)
		WHERE UF_DATE >= @Start AND UF_DATE < DATEADD(DAY, 1, @Finish) AND UF_PATH = 3

	SET @SQL = N'CREATE INDEX [IX_' + CONVERT(VARCHAR(50), NEWID()) + '] ON #update (ClientID) INCLUDE(UpdateDateTime)'

	EXEC (@SQL)
		
	IF OBJECT_ID('tempdb..#compl') IS NOT NULL
		DROP TABLE #compl
	
	IF OBJECT_ID('tempdb..#actual') IS NOT NULL
		DROP TABLE #actual

	IF OBJECT_ID('tempdb..#skip') IS NOT NULL
		DROP TABLE #skip

	IF OBJECT_ID('tempdb..#lost') IS NOT NULL
		DROP TABLE #lost
		
	IF OBJECT_ID('tempdb..#search') IS NOT NULL
		DROP TABLE #search
	
	CREATE TABLE #compl
		(
			ClientID	INT,
			WeekID		INT,
			Comp		VARCHAR(MAX)
		)
		
	INSERT INTO #compl(ClientID, WeekID, Comp)
		SELECT CL_ID, Week_ID, 
			REVERSE(STUFF(REVERSE(
					(
						SELECT InfoBankShortName + ', '
						FROM 
							(
								SELECT DISTINCT InfoBankShortName, InfoBankOrder
								FROM 
									USR.USRIBComplianceView WITH(NOEXPAND)
									INNER JOIN dbo.InfoBankTable ON InfoBankID = UI_ID_BASE									
								WHERE UI_LAST >= WBEGIN AND UI_LAST <= WEND
									AND CL_ID = UD_ID_CLIENT
									AND InfoBankActive = 1
							) AS o_O
						ORDER BY InfoBankOrder FOR XML PATH(''))
					), 1, 2, '')
				)
		FROM #client CROSS JOIN @Weeks

	SET @SQL = N'CREATE CLUSTERED INDEX [IX_' + CONVERT(VARCHAR(50), NEWID()) + '] ON #compl (ClientID)'

	EXEC (@SQL)

	CREATE TABLE #actual
		(
			ClientID	INT,
			WeekID		INT,
			Actual		VARCHAR(MAX)
		)

	INSERT INTO #actual(ClientID, WeekID, Actual)
		SELECT DISTINCT
			a.ClientID, Week_ID,
			REVERSE(STUFF(REVERSE(
				(	
					SELECT InfoBankShortName + ', '
					FROM 
						(
							SELECT DISTINCT InfoBankShortName, InfoBankOrder
							FROM
								#usrdata z
								INNER JOIN dbo.InfoBankTable y ON z.InfoBankID = y.InfoBankID 
								INNER JOIN dbo.StatisticTable x ON x.InfoBankID = y.InfoBankID
							WHERE UD_ID_CLIENT = a.ClientID
								AND UIU_DATE_S >= WBEGIN 
								AND UIU_DATE_S <= WEND
								AND Docs = z.UIU_DOCS 
								AND InfoBankActual = 1
								AND InfoBankActive = 1
								AND z.UIU_DATE_S = CONVERT(SMALLDATETIME, CONVERT(VARCHAR(20), b.UpdateDateTime, 112), 112)
								AND 
									(
										SELECT TOP 1 CalendarDate
										FROM dbo.Calendar
										WHERE CalendarIndex = 
												(
													SELECT TOP 1 CalendarIndex
													FROM 
														dbo.Calendar INNER JOIN
														dbo.DayTable ON DayID = CalendarWeekDayID
													WHERE CalendarDate >= StatisticDate
														AND DayOrder = 1
														AND CalendarWork = 1
													ORDER BY CalendarDate
												) + 
												CASE InfoBankDaily
													WHEN 1 THEN TypeDailyDays
													ELSE TypeDays
												END - 1
											AND CalendarWork = 1
										ORDER BY CalendarDate
									) < UIU_DATE_S
								/*
									CASE InfoBankDaily
										WHEN 1 THEN dbo.WorkDaysAdd(StatisticDate, TypeDailyDays) 
										ELSE dbo.WorkDaysAdd(StatisticDate, TypeDays) 
									END < UIU_DATE_S
								*/
						) AS o_O
					ORDER BY InfoBankOrder FOR XML PATH('')
				)), 1, 2, ''))
		FROM 
			#res a
			INNER JOIN #update b ON a.ClientID = b.ClientID AND UF_PATH <> 3
			CROSS JOIN @Weeks

	SET @SQL = N'CREATE CLUSTERED INDEX [IX_' + CONVERT(VARCHAR(50), NEWID()) + '] ON #actual (ClientID)'

	EXEC (@SQL)

	CREATE TABLE #skip
		(
			ClientID	INT,
			WeekID		INT
		)

	INSERT INTO #skip(ClientID, WeekID)
		SELECT 
			CL_ID, Week_ID
		FROM #client CROSS JOIN @Weeks
		WHERE NOT EXISTS
			(
				SELECT *
				FROM #usrdata
				WHERE CL_ID = UD_ID_CLIENT
					AND UIU_DATE_S >= WBEGIN AND UIU_DATE_S <= WEND
			)
	
	SET @SQL = N'CREATE CLUSTERED INDEX [IX_' + CONVERT(VARCHAR(50), NEWID()) + '] ON #skip (ClientID)'

	EXEC (@SQL)

	CREATE TABLE #lost
		(
			ClientID	INT,
			WeekID		INT,
			LostList	VARCHAR(MAX)
		)

	INSERT INTO #lost(ClientID, WeekID, LostList)
		SELECT 
			CL_ID, Week_ID,
			REVERSE(STUFF(REVERSE(
				(										
					SELECT InfoBankShortName + ', '
					FROM 
						(
							SELECT DISTINCT 
								InfoBankShortName, 
								InfoBankOrder,
								z.SystemOrder
							FROM 
								(
									SELECT ID_CLIENT, InfoBankID, DISTR, COMP, InfoBankShortName, InfoBankOrder, z.SystemOrder
									FROM 
										dbo.ClientDistrView z WITH(NOEXPAND)
										CROSS APPLY dbo.SystemBankGet(z.SystemID, z.DistrTypeId) x
									WHERE z.ID_CLIENT = CL_ID 
										AND z.SystemBaseName NOT IN (/*'RGU', 'RGN', */'CMT', 'QSA', 'ARB', 'JUR', 'BUD', 'MBP', 'BVP', 'JURP', 'BUDP')
										AND z.DS_REG = 0
										AND InfoBankActive = 1
										AND Required = 1
										AND SystemBaseCheck = 1 AND DistrTypeBaseCheck = 1
										AND	InfoBankStart <= WBEGIN
										
									UNION
										
									SELECT ID_CLIENT, InfoBankID, DISTR, COMP, InfoBankShortName, InfoBankOrder, z.SystemOrder
									FROM 
										dbo.ClientDistrView z WITH(NOEXPAND)
										CROSS APPLY dbo.SystemBankGet(z.SystemID, z.DistrTypeId) x
									WHERE z.ID_CLIENT = CL_ID AND z.SystemBaseName = 'CMT'
										AND z.DS_REG = 0
										AND InfoBankActive = 1
										AND Required = 1
										AND SystemBaseCheck = 1 AND DistrTypeBaseCheck = 1
										AND InfoBankName NOT IN ('PKG', 'PSG', 'PPVS')
										AND	InfoBankStart <= WBEGIN
										
									UNION
										
									SELECT ID_CLIENT, InfoBankID, DISTR, COMP, InfoBankShortName, InfoBankOrder, z.SystemOrder
									FROM 
										dbo.ClientDistrView z WITH(NOEXPAND)
										CROSS APPLY dbo.SystemBankGet(z.SystemID, z.DistrTypeId) x
									WHERE z.ID_CLIENT = CL_ID AND z.SystemBaseName = 'QSA'
										AND z.DS_REG = 0
										AND InfoBankActive = 1
										AND Required = 1
										AND SystemBaseCheck = 1 AND DistrTypeBaseCheck = 1
										AND InfoBankName NOT IN ('PKV')
										AND	InfoBankStart <= WBEGIN
										
									UNION
										
									SELECT ID_CLIENT, InfoBankID, DISTR, COMP, InfoBankShortName, InfoBankOrder, z.SystemOrder
									FROM 
										dbo.ClientDistrView z WITH(NOEXPAND)
										CROSS APPLY dbo.SystemBankGet(z.SystemID, z.DistrTypeId) x
									WHERE z.ID_CLIENT = CL_ID AND z.SystemBaseName IN ('ARB', 'JUR', 'BUD', 'MBP', 'BVP', 'JURP', 'BUDP')
										AND z.DS_REG = 0
										AND InfoBankActive = 1
										AND Required = 1
										AND SystemBaseCheck = 1 AND DistrTypeBaseCheck = 1
										AND InfoBankName NOT IN ('BRB')
										AND	InfoBankStart <= WBEGIN									
										
									UNION
									
									SELECT ID_CLIENT, InfoBankID, DISTR, COMP, InfoBankShortName, InfoBankOrder, z.SystemOrder
									FROM 
										dbo.ClientDistrView z WITH(NOEXPAND)
										CROSS APPLY dbo.SystemBankGet(z.SystemID, z.DistrTypeId) x
									WHERE z.ID_CLIENT = CL_ID AND z.SystemBaseName = 'CMT'
										AND z.DS_REG = 0
										AND InfoBankActive = 1
										AND Required = 1
										AND SystemBaseCheck = 1 AND DistrTypeBaseCheck = 1
										AND InfoBankName IN ('PKG', 'PSG', 'PPVS')
										AND	InfoBankStart <= WBEGIN
										AND NOT EXISTS
											(
												SELECT *
												FROM 
													dbo.ClientDistrView t WITH(NOEXPAND)
													CROSS APPLY dbo.SystemBankGet(t.SystemID, t.DistrTypeId) q
												WHERE t.ID_CLIENT = z.ID_CLIENT 
													AND t.SystemID = q.SystemID
													AND t.DS_REG = 0 
													AND InfoBankActive = 1 
													AND Required = 1
													AND q.SystemBaseName = 'BUD'
											)
											
									UNION
									
									SELECT ID_CLIENT, InfoBankID, DISTR, COMP, InfoBankShortName, InfoBankOrder, z.SystemOrder
									FROM 
										dbo.ClientDistrView z WITH(NOEXPAND)
										CROSS APPLY dbo.SystemBankGet(z.SystemID, z.DistrTypeId) x
									WHERE z.ID_CLIENT = CL_ID AND z.SystemBaseName = 'QSA'
										AND z.DS_REG = 0
										AND InfoBankActive = 1
										AND Required = 1
										AND SystemBaseCheck = 1 AND DistrTypeBaseCheck = 1
										AND InfoBankName IN ('PKV')
										AND	InfoBankStart <= WBEGIN
										AND NOT EXISTS
											(
												SELECT *
												FROM 
													dbo.ClientDistrView t WITH(NOEXPAND)
													CROSS APPLY dbo.SystemBankGet(t.SystemID, t.DistrTypeId) q
												WHERE t.ID_CLIENT = z.ID_CLIENT 
													AND t.SystemID = q.SystemID
													AND t.DS_REG = 0 
													AND InfoBankActive = 1 
													AND Required = 1
													AND q.SystemBaseName = 'BUD'
											)
								) AS z
							WHERE NOT EXISTS
									(
										SELECT *
										FROM #usrdata p
										WHERE UIU_DATE_S >= WBEGIN AND UIU_DATE_S <= WEND
											AND z.InfoBankID = p.InfoBankID											
											AND CL_ID = UD_ID_CLIENT
											AND UI_DISTR = DISTR
											AND UI_COMP = COMP
									)
						) AS asdasd
					ORDER BY SystemOrder, InfoBankOrder FOR XML PATH('')
				)), 1, 2, ''))				
		FROM #client CROSS JOIN @Weeks
		WHERE NOT EXISTS
			(
				SELECT *
				FROM #skip
				WHERE CL_ID = ClientID AND WeekID = Week_ID
			)

	CREATE TABLE #search
		(
			ClientID	INT,
			LastFile	SMALLDATETIME
		)
		
	INSERT INTO #search(ClientID, LastFile)
		SELECT CL_ID, dbo.DateOf(MAX(SearchGet))
		FROM
			#client
			INNER JOIN dbo.ClientSearchTable ON ClientID = CL_ID
		WHERE SearchGet >= DATEADD(MONTH, -1, @Finish)
		GROUP BY CL_ID

	SET @SQL = N'CREATE CLUSTERED INDEX [IX_' + CONVERT(VARCHAR(50), NEWID()) + '] ON #lost (ClientID)'

	EXEC (@SQL)

	IF OBJECT_ID('tempdb..#total') IS NOT NULL
		DROP TABLE #total

	SELECT 
		ID, ClientID, CLientFullName, SystemList, ClientTypeName, ServiceType, ServiceDay, DayOrder, DayTime,
		ClientEvent, UpdateDayTime, UpdateDay, ResVersion, ConsExe, ResActual, ConsExeActual, UpdateDateTime,
		ActualError, REPLACE(Actual, '&#x0A;', CHAR(10)) AS Actual, 
		ComplianceError, REPLACE(Compliance, '&#x0A;', CHAR(10)) AS Compliance, 
		UpdateSkipError, REPLACE(UpdateSkip, '&#x0A;', CHAR(10)) AS UpdateSkip, 
		UpdateLostError,  REPLACE(UpdateLost, '&#x0A;', CHAR(10)) AS UpdateLost, 
		CASE 
			WHEN UpdateSkipError = 1 THEN 'Нарушена' 
			ELSE NULL 
		END AS UpdatePeriod,
		LastSearch,
		UF_PATH,
		LastSTT
	INTO #total
	FROM
		(		
			SELECT DISTINCT
				ID, a.ClientID, CLientFullName, SystemList, ClientTypeName, ServiceType, ServiceDay, DayOrder, DayTime,
				ClientEvent, LastSTT,
					LEFT(CONVERT(VARCHAR(20), UpdateDateTime, 104) ,5) + ' ' + 
					/*DATENAME(WEEKDAY, UpdateDateTime) + ' ' + */
					WD + ' ' +
					LEFT(CONVERT(VARCHAR(20), UpdateDateTime, 108), 5) AS UpdateDayTime,
				DATEPART(WEEKDAY, UpdateDateTime) AS UpdateDay, 
				CASE DistrTypeBaseCheck
					WHEN 0 THEN ''
					ELSE ResVersion
				END AS ResVersion, 
				CASE DistrTypeBaseCheck
					WHEN 0 THEN ''
					ELSE ConsExe
				END AS ConsExe, 
				CASE DistrTypeBaseCheck
					WHEN 0 THEN 1
					ELSE ResActual
				END AS ResActual, 
				CASE DistrTypeBaseCheck
					WHEN 0 THEN 1
					ELSE ConsExeActual
				END AS ConsExeActual, UpdateDateTime,
				UF_PATH,
				CASE
					WHEN EXISTS
						(
							SELECT *
							FROM #compl z
							WHERE z.ClientID = a.ClientID
								AND Comp IS NOT NULL
						) THEN 1 
					ELSE 0 
				END AS ComplianceError,
				CASE
					WHEN DistrTypeBaseCheck = 0 THEN ''
					WHEN EXISTS
						(
							SELECT *
							FROM #compl z
							WHERE z.ClientID = a.ClientID
								AND Comp IS NOT NULL
						) THEN '' + 						
							(
								SELECT 
									ISNULL('с ' + CONVERT(VARCHAR(20), WBEGIN, 104) + ' по ' + CONVERT(VARCHAR(20), WEND, 104) + ': ' + Comp + CHAR(10), '')
								FROM 
									@Weeks INNER JOIN
									#compl z ON Week_ID = WeekID
								WHERE z.ClientID = a.ClientID
								ORDER BY Week_ID FOR XML PATH('')							
							)
					ELSE 'Совпадает'
				END AS Compliance,
				CASE
					WHEN DistrTypeBaseCheck = 0 THEN 0
					WHEN EXISTS
						(
							SELECT *
							FROM #actual z
							WHERE z.ClientID = a.ClientID
								AND Actual IS NOT NULL
						) THEN 1 
					ELSE 0 
				END AS ActualError,
				CASE
					WHEN DistrTypeBaseCheck = 0 THEN ''
					WHEN EXISTS
						(
							SELECT *
							FROM #actual z
							WHERE z.ClientID = a.ClientID
								AND Actual IS NOT NULL
						) THEN '' + 
							(
								SELECT 
									ISNULL('с ' + CONVERT(VARCHAR(20), WBEGIN, 104) + ' по ' + CONVERT(VARCHAR(20), WEND, 104) + ': ' + Actual + CHAR(10), '') 
								FROM 
									@Weeks INNER JOIN
									#actual z ON Week_ID = WeekID
								WHERE z.ClientID = a.ClientID
								ORDER BY Week_ID FOR XML PATH('')							
							)
					ELSE 'Актуально'
				END AS Actual,
				CASE
					WHEN DIstrTypeBaseCheck = 0 THEN 0
					WHEN EXISTS
						(
							SELECT *
							FROM #skip z
							WHERE z.ClientID = a.ClientID
						) THEN 1 
					ELSE 0 
				END AS UpdateSkipError,
				CASE
					WHEN DistrTypeBaseCheck = 0 THEN ''
					WHEN EXISTS
						(
							SELECT *
							FROM #skip z
							WHERE z.ClientID = a.ClientID
						) THEN '' + 						
							(
								SELECT 
									ISNULL('с ' + CONVERT(VARCHAR(20), WBEGIN, 104) + ' по ' + CONVERT(VARCHAR(20), WEND, 104) + CHAR(10), '')
								FROM 
									@Weeks INNER JOIN
									#skip z ON Week_ID = WeekID
								WHERE z.ClientID = a.ClientID
								ORDER BY Week_ID FOR XML PATH('')							
							)
					ELSE ''
				END AS UpdateSkip,
				CASE
					WHEN DistrTypeBaseCheck = 0 THEN 0
					WHEN EXISTS
						(
							SELECT *
							FROM #lost z
							WHERE z.ClientID = a.ClientID
								AND LostList IS NOT NULL
						) THEN 1 
					ELSE 0 
				END AS UpdateLostError,
				CASE
					WHEN DistrTypeBaseCheck = 0 THEN ''
					WHEN EXISTS
						(
							SELECT *
							FROM #lost z
							WHERE z.ClientID = a.ClientID
								AND LostList IS NOT NULL
						) THEN '' + 						
							(
								SELECT 
									ISNULL('с ' + CONVERT(VARCHAR(20), WBEGIN, 104) + ' по ' + CONVERT(VARCHAR(20), WEND, 104) + ': ' + LostList + CHAR(10), '')
								FROM 
									@Weeks INNER JOIN
									#lost z ON Week_ID = WeekID
								WHERE z.ClientID = a.ClientID
								ORDER BY Week_ID FOR XML PATH('')							
							)
					ELSE ''
				END AS UpdateLost,
				(
					SELECT CONVERT(VARCHAR(20), LastFile, 104)
					FROM #search z
					WHERE z.ClientID = a.ClientID
				) AS LastSearch
			FROM 
				#res a LEFT OUTER JOIN
				#update b ON a.ClientID = b.ClientID
		) AS o_O
	ORDER BY ID, ClientFullName, UpdateDateTime
	
	SELECT *, (SELECT COUNT(*) FROM #total b WHERE a.ID = b.ID) AS ROW_CNT
	FROM #total a
	ORDER BY ID, ClientFullName, UpdateDateTime

	IF OBJECT_ID('tempdb..#res') IS NOT NULL
		DROP TABLE #res

	IF OBJECT_ID('tempdb..#update') IS NOT NULL
		DROP TABLE #update

	IF OBJECT_ID('tempdb..#usrdata') IS NOT NULL
		DROP TABLE #usrdata

	IF OBJECT_ID('tempdb..#usr') IS NOT NULL
		DROP TABLE #usr
	
	IF OBJECT_ID('tempdb..#client') IS NOT NULL
		DROP TABLE #client

	IF OBJECT_ID('tempdb..#compl') IS NOT NULL
		DROP TABLE #compl

	IF OBJECT_ID('tempdb..#actual') IS NOT NULL
		DROP TABLE #actual

	IF OBJECT_ID('tempdb..#skip') IS NOT NULL
		DROP TABLE #skip	
	
	IF OBJECT_ID('tempdb..#lost') IS NOT NULL
		DROP TABLE #lost
		
	IF OBJECT_ID('tempdb..#search') IS NOT NULL
		DROP TABLE #search
		
	IF OBJECT_ID('tempdb..#total') IS NOT NULL
		DROP TABLE #total
END

