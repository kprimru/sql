USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [USR].[SERVICE_COMMON_NEW_GRAPH]
	@SERVICE	INT,
	@BEGIN		SMALLDATETIME,
	@END		SMALLDATETIME,
	@TYPE		VARCHAR(MAX) = NULL
AS
BEGIN
	SET NOCOUNT ON;
	
	DECLARE @WEEK TABLE
	(
		WEEK_ID	INT,
		WBEGIN SMALLDATETIME, 
		WEND SMALLDATETIME,
		PRIMARY KEY CLUSTERED(WEEK_ID)
	);

	INSERT INTO @WEEK
	SELECT *
	FROM dbo.WeekDates(@BEGIN, @END);
	

	DECLARE @MON_BEGIN	SMALLDATETIME
	DECLARE @MON_END	SMALLDATETIME
	
	SET @MON_BEGIN = CAST(CONVERT(CHAR(6), @END, 112) + '01' AS SMALLDATETIME)
	SET @MON_END = CAST(CONVERT(CHAR(6), DATEADD(MONTH, 1, @END), 112) + '01' AS SMALLDATETIME)

	DECLARE @SQL NVARCHAR(MAX)

	DECLARE @client Table
	(
		CL_ID		INT,
		Complect	VarChar(100),
		ComplectStr	VarChar(100),
		Primary Key Clustered (CL_ID, Complect)
	);
	
	DECLARE @Clientdistr Table
	(
		ClientId			Int,
		Complect			VarChar(100),
		HostId				SmallInt,
		SystemId			SmallInt,
		Distr				Int,
		Comp				TinyInt,
		DistrTypeId			SmallInt,
		SystemBaseName		VarChar(50),
		SystemBaseCheck		Bit,
		DistrTypeBaseCheck	Bit,
		SystemOrder			Int,
		DistrStr			VarCHar(100),
		DIstrTypeName		VarCHar(100),
		PRIMARY KEY CLUSTERED(ClientId, Complect, SystemId, Distr, Comp)
	);

	INSERT INTO @client
	SELECT ClientID, Complect, ComplectStr
	FROM dbo.ClientTable a
	CROSS APPLY
	(
		SELECT
			Complect,
			ComplectStr = DistrStr
		FROM dbo.RegNodeComplectClientView t
		WHERE ClientID = a.ClientId
			AND DS_REG = 0
	) t
	INNER JOIN (
		SELECT Item 
		FROM dbo.GET_TABLE_FROM_LIST(@TYPE, ',')
	) AS o_O ON a.ServiceTypeID = Item
	WHERE ClientServiceID  = @SERVICE 
		AND StatusID = 2
		AND STATUS = 1;

	INSERT INTO @Clientdistr
	SELECT c.CL_ID, c.Complect, d.HostId, d.SystemId, d.DISTR, d.COMP, d.DistrTypeId, d.SystemBaseName, SystemBaseCheck, DistrTypeBaseCheck, d.SystemOrder, d.DistrStr, d.DistrTypeName
	FROM @Client c
	INNER JOIN dbo.CLientDistrView d WITH(NOEXPAND) ON d.ID_CLIENT = c.CL_ID
	INNER JOIN Reg.RegNodeSearchView r WITH(NOEXPAND) ON d.Distr = r.DistrNumber AND d.Comp = r.CompNumber AND d.HostId = r.HostId AND r.Complect = c.Complect
	WHERE d.DS_REG = 0;

	-- убираем из отчета все комплекты, в которых нет ни одного дистрибутива, которын надо провер€ть
	DELETE c
	FROM @Client c
	WHERE NOT EXISTS
		(
			SELECT *
			FROM @ClientDIstr d
			WHERE c.CL_ID = d.CLientID
				AND d.Complect = c.Complect
				AND d.SYstemBaseCheck = 1
				AND d.DistrTypeBaseCheck = 1
		);
	
	DECLARE @ip Table
	(
		SYS		SMALLINT,
		DISTR	INT,
		COMP	TINYINT,
		DATE	DATETIME,
		PRIMARY KEY CLUSTERED(DISTR, SYS, COMP)
	);
		
	INSERT INTO @ip(SYS, DISTR, COMP, DATE)
	SELECT CSD_SYS, CSD_DISTR, CSD_COMP, MAX(ISNULL(CSD_START, CSD_END))
	FROM dbo.IPSTTView
	WHERE CSD_START >= @MON_BEGIN AND CSD_START < @MON_END
	GROUP BY CSD_SYS, CSD_DISTR, CSD_COMP;

	DECLARE @usr TABLE
	(
		ClientID		INT,
		Complect		VarChar(100),
		ResVersion		VarChar(50),
		ConsExeVersion	VarChar(50),
		PRIMARY KEY CLUSTERED(ClientId, Complect)
	);

	INSERT INTO @usr(ClientID, Complect, ResVersion, ConsExeVersion)
	SELECT DISTINCT CL_ID, x.Complect, t.UF_ID_RES, t.UF_ID_CONS
	FROM 
		@client 
		INNER JOIN USR.USRActiveView z ON z.UD_ID_CLIENT = CL_ID
		INNER JOIN USR.USRFileTech t ON z.UF_ID = t.UF_ID
		INNER JOIN dbo.SystemTable y ON z.UF_ID_SYSTEM = y.SystemID 
		INNER JOIN dbo.RegNodeTable x ON x.SystemName = SystemBaseName AND z.UD_DISTR = x.DistrNumber AND z.UD_COMP = x.CompNumber
	WHERE Service = 0
	OPTION (RECOMPILE);

	DECLARE @res Table
	(
		ID						INT,
		ClientID				INT,
		Complect				VarChar(100),
		ComplectStr				VarCHar(100),
		ClientFullName			VARCHAR(250),
		SystemList				VARCHAR(500),
		ClientTypeName			VARCHAR(10),
		TypeDailyDays			TINYINT,
		TypeDays				TINYINT,
		ServiceType				VARCHAR(50),
		DayOrder				SMALLINT,			
		ServiceDay				VARCHAR(50),
		DayTime					DATETIME,
		ResVersion				VARCHAR(150),
		ConsExe					VARCHAR(150),
		ConsExeActual			INT,
		ResActual				INT,
		ClientEvent				VARCHAR(MAX),
		DistrTypeBaseCheck		TINYINT,
		LastSTT					VARCHAR(20)
		PRIMARY KEY CLUSTERED(ClientId, Complect)
	);
		
	/* формируем кост€к дл€ итоговой таблицы.*/
	INSERT INTO @res(
			ID, ClientID, Complect, ComplectStr, ClientFullName, SystemList, ClientTypeName, TypeDailyDays, TypeDays, ServiceType, 
			DayOrder, ServiceDay, DayTime, ResVersion, ConsExe, ConsExeActual, ResActual, ClientEvent, DistrTypeBaseCheck, LastStt)
		SELECT 
			ROW_NUMBER() OVER(ORDER BY ClientFullName),
			a.ClientID, t.Complect, t.ComplectStr, ClientFullName, 
			REVERSE(STUFF(REVERSE(
				(
					SELECT
						DistrStr + ' (' + DistrTypeName + '), '
					FROM @ClientDIstr y
					WHERE y.CLientId = a.ClientID
						AND y.Complect = t.Complect
					ORDER BY SystemOrder FOR XML PATH('')
				)
			), 1, 2, '')),
			ClientTypeName, ClientTypeDailyDay, 
			ClientTypeDay, ServiceTypeShortName, DayOrder,
			ISNULL(c.DayShort, '') + ' ' + ISNULL(LEFT(CONVERT(VARCHAR(20), ServiceStart, 108), 5), ''), ServiceStart,
			/* вписываем через зап€тую все технологические модули, версии cons.exe дл€
			 активных комплектов, в которых основна€ система сопровождаетс€.
			 а также вычисл€ем, если есть устаревшие модули или cons.exe - выводим признак
			*/
			rv.ResVersionShort, rv.ConsExeVersionName, ConsExeVersionActive, IsLatest,
			REVERSE(STUFF(REVERSE((
				SELECT 
					CONVERT(VARCHAR(20), EventDate, 104) + '    ' + 
					EventComment + CHAR(10) + CHAR(10)
				FROM
					dbo.EventTable z INNER JOIN
					dbo.EventTypeTable y ON z.EventTypeID = y.EventTypeID
				WHERE z.ClientID = a.ClientID
					AND EventDate >= @BEGIN AND EventDate <= @END
					AND EventActive = 1
					AND EventTypeName NOT IN (' √— 223', ' √— 94') 
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
						INNER JOIN @ClientDistr y ON z.DISTR = y.DISTR AND z.COMP = y.COMP 
						INNER JOIN dbo.SystemTable x ON x.HostID = y.HostID AND x.SystemNumber = z.SYS_NUM
					WHERE y.ClientId = a.ClientID
						AND y.Complect = t.Complect
						AND DATE >= @MON_BEGIN AND DATE < @MON_END
				)), 104) + '',
				CONVERT(VARCHAR(20), dbo.DateOf(
				(
					SELECT MAX(DATE)
					FROM 
						@ip z
						INNER JOIN @CLientDistr y ON z.DISTR = y.DISTR AND z.COMP = y.COMP 
						INNER JOIN dbo.SystemTable x ON x.SystemID = y.SystemID AND x.SystemNumber = z.SYS
					WHERE y.ClientId = a.ClientID
						AND y.Complect = t.COmplect
				)), 104) + ' (»)')
		FROM @Client t
		INNER JOIN dbo.ClientTable a ON t.CL_ID = a.ClientId
		INNER JOIN dbo.ServiceTypeTable d ON d.ServiceTypeID = a.ServiceTypeID 
		INNER JOIN dbo.ClientTypeAllView r ON r.ClientID = a.ClientID
		LEFT JOIN dbo.ClientTypeTable b ON r.CATEGORY = b.ClientTypeName
		LEFT JOIN dbo.DayTable c ON a.DayID = c.DayID
		OUTER APPLY
		(
			SELECT TOP (1) ResVersionShort, ConsExeVersionName, ConsExeVersionActive, IsLatest
			FROM @usr z
			LEFT JOIN dbo.ResVersionTable ON ResVersionID = ResVersion
			LEFT JOIN dbo.ConsExeVersionTable ON ConsExeVersionID = ConsExeVersion
			WHERE z.ClientID = a.ClientID
				AND z.Complect = t.Complect
		) rv
		ORDER BY ClientFullName
		OPTION (RECOMPILE)
		
	DECLARE @update Table
	(
		ClientID			INT,
		Complect			VarCHar(100),
		UF_PATH				TINYINT,		
		UpdateDateTime		DATETIME,
		WD					CHAR(2),
		Primary Key Clustered (ClientId, Complect, UpdateDateTime, WD, UF_PATH)
	);

	DECLARE @usrdata Table
	(
		ID					INT IDENTITY(1, 1),
		UD_ID_CLIENT		INT,
		Complect			VarChar(100),
		UF_PATH				TINYINT,
		UI_DISTR			INT,
		UI_COMP				TINYINT,
		UIU_DATE			SMALLDATETIME,
		UIU_DATE_S			SMALLDATETIME,
		UIU_DOCS			INT,
		InfoBankID			INT
		PRIMARY KEY CLUSTERED(UD_ID_CLIENT, Id)
	);

	-- тут несколько костыльно поредел€ем к какому комплекту принадлежит пополнение. ¬полне может быть коллизи€, если у клиента
	-- в разных комплектах будет нечто с одним номером дистрибутива
	INSERT INTO @usrdata(UD_ID_CLIENT, Complect, UF_PATH, UI_DISTR, UI_COMP, UIU_DATE, UIU_DATE_S, UIU_DOCS, InfoBankID)
	SELECT DISTINCT UD_ID_CLIENT, c.Complect, UF_PATH, UI_DISTR, UI_COMP, UIU_DATE, UIU_DATE_S, UIU_DOCS, UI_ID_BASE
	FROM @client c
	INNER JOIN @clientdistr d ON c.CL_ID = d.ClientId AND c.Complect = d.Complect
	INNER JOIN USR.USRIBDateView u WITH(NOEXPAND) ON UD_ID_CLIENT = CL_ID AND u.UI_DISTR = d.DISTR AND u.UI_COMP = d.COMP
	WHERE UIU_DATE_S >= @BEGIN AND UIU_DATE_S <= @END
	OPTION (RECOMPILE);
	
	INSERT INTO @update(ClientID, Complect, UF_PATH, UpdateDateTime, WD)
	SELECT DISTINCT
		UD_ID_CLIENT, Complect, 1,
		CONVERT(DATETIME, LEFT(CONVERT(VARCHAR(50), c.UIU_DATE_S, 121), 10) + ' ' +
			(
				SELECT MIN(LEFT(CONVERT(VARCHAR(20), t.UIU_DATE, 114), 5))
				FROM @usrdata t
				WHERE t.UD_ID_CLIENT = c.UD_ID_CLIENT
					AND t.Complect = c.Complect
					AND t.UIU_DATE_S = c.UIU_DATE_S
			) + ':00', 121),
		DayShort
	FROM 
	(
		SELECT DISTINCT UD_ID_CLIENT, Complect, UF_PATH, UIU_DATE_S
		FROM @usrdata d
	) AS c
	INNER JOIN dbo.DayTable ON DayOrder = DATEPART(WEEKDAY, UIU_DATE_S)
	OPTION (RECOMPILE)
		
	INSERT INTO @update(ClientID, Complect, UF_PATH, UpdateDateTime, WD)
	SELECT DISTINCT
		UD_ID_CLIENT, Complect, UF_PATH,
		UF_DATE,
		DayShort
	FROM 
		@client c
		-- вот это еще больший костыль. Ќадо перерабатывать структуру хранени€ данных, чтобы разбиратьс€, что есть комплект
		INNER JOIN USR.USRData d ON UD_ID_CLIENT = CL_ID AND Complect LIKE '%' + Cast(UD_DISTR AS VarCHar(100)) + '%'
		INNER JOIN USR.USRFile f ON UF_ID_COMPLECT = UD_ID
		INNER JOIN dbo.DayTable t ON DayOrder = DATEPART(WEEKDAY, UF_DATE)
	WHERE UF_DATE >= @BEGIN AND UF_DATE < DATEADD(DAY, 1, @END) AND UF_PATH = 3
		AND NOT EXISTS
		(
			SELECT *
			FROM @Update z
			WHERE z.ClientId = UD_ID_CLIENT
				AND z.Complect = c.Complect
				AND z.UF_PATH = f.UF_PATH
				AND z.UpdateDateTime = f.UF_DATE
				AND z.WD = t.DayShort
		)
	OPTION (RECOMPILE)
	
	DECLARE @compl Table
	(
		ClientID	INT,
		Complect	VarChar(100),
		WeekID		INT,
		Comp		VARCHAR(MAX),
		Primary Key Clustered(ClientId, Complect, WeekID)
	);
		
	-- ToDo. ѕока что в списке несоответствующих эталону будут множитьс€ по всем комплектам клиента
	INSERT INTO @compl(ClientID, Complect, WeekID, Comp)
	SELECT CL_ID, Complect, Week_ID, 
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
	FROM @client CROSS JOIN @week
	OPTION (RECOMPILE)

	DECLARE @skip Table
	(
		ClientID	INT,
		Complect	VarChar(100),
		WeekID		INT,
		Primary Key Clustered(ClientId, Complect, WeekId)
	);

	INSERT INTO @skip(ClientID, Complect, WeekID)
	SELECT 
		CL_ID, Complect, Week_ID
	FROM @client c CROSS JOIN @WEEK
	WHERE NOT EXISTS
		(
			SELECT *
			FROM @usrdata u
			WHERE CL_ID = UD_ID_CLIENT
				AND c.Complect = u.Complect
				AND UIU_DATE_S >= WBEGIN AND UIU_DATE_S <= WEND
		)
	OPTION(RECOMPILE)

	DECLARE @lost Table
	(
		ClientID	INT,
		Complect	VarCHar(100),
		WeekID		INT,
		LostList	VARCHAR(MAX),
		Primary Key Clustered(ClientId, Complect, WeekId)
	);

	INSERT INTO @lost(ClientID, Complect, WeekID, LostList)
	SELECT 
		CL_ID, Complect, Week_ID,
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
								SELECT ID_CLIENT = z.ClientId, InfoBankID, DISTR, COMP, InfoBankShortName, InfoBankOrder, z.SystemOrder
								FROM @ClientDIstr z
								CROSS APPLY dbo.SystemBankGet(z.SystemID, z.DistrTypeId) x
								WHERE z.ClientId = CL_ID 
									AND z.Complect = c.Complect
									AND z.SystemBaseName NOT IN (/*'RGU', 'RGN', */'CMT', 'QSA', 'ARB', 'JUR', 'BUD', 'MBP', 'BVP', 'JURP', 'BUDP')
									AND InfoBankActive = 1
									AND Required = 1
									AND SystemBaseCheck = 1 AND DistrTypeBaseCheck = 1
									AND	InfoBankStart <= WBEGIN
									
								UNION
									
								SELECT ID_CLIENT = z.ClientId, InfoBankID, DISTR, COMP, InfoBankShortName, InfoBankOrder, z.SystemOrder
								FROM @ClientDIstr z
								CROSS APPLY dbo.SystemBankGet(z.SystemID, z.DistrTypeId) x
								WHERE z.ClientId = CL_ID 
									AND z.Complect = c.Complect
									AND z.SystemBaseName = 'CMT'
									AND InfoBankActive = 1
									AND Required = 1
									AND SystemBaseCheck = 1 AND DistrTypeBaseCheck = 1
									AND InfoBankName NOT IN ('PKG', 'PSG', 'PPVS')
									AND	InfoBankStart <= WBEGIN
									
								UNION
									
								SELECT ID_CLIENT = z.ClientId, InfoBankID, DISTR, COMP, InfoBankShortName, InfoBankOrder, z.SystemOrder
								FROM @ClientDIstr z
								CROSS APPLY dbo.SystemBankGet(z.SystemID, z.DistrTypeId) x
								WHERE z.ClientId = CL_ID 
									AND z.Complect = c.Complect
									AND z.SystemBaseName = 'QSA'
									AND InfoBankActive = 1
									AND Required = 1
									AND SystemBaseCheck = 1 AND DistrTypeBaseCheck = 1
									AND InfoBankName NOT IN ('PKV')
									AND	InfoBankStart <= WBEGIN
									
								UNION
									
								SELECT ID_CLIENT = z.ClientId, InfoBankID, DISTR, COMP, InfoBankShortName, InfoBankOrder, z.SystemOrder
								FROM @ClientDIstr z
								CROSS APPLY dbo.SystemBankGet(z.SystemID, z.DistrTypeId) x
								WHERE z.ClientId = CL_ID 
									AND z.Complect = c.Complect
									AND z.SystemBaseName IN ('ARB', 'JUR', 'BUD', 'MBP', 'BVP', 'JURP', 'BUDP')
									AND InfoBankActive = 1
									AND Required = 1
									AND SystemBaseCheck = 1 AND DistrTypeBaseCheck = 1
									AND InfoBankName NOT IN ('BRB')
									AND	InfoBankStart <= WBEGIN									
									
								UNION
								
								SELECT ID_CLIENT = z.ClientId, InfoBankID, DISTR, COMP, InfoBankShortName, InfoBankOrder, z.SystemOrder
								FROM @ClientDIstr z
								CROSS APPLY dbo.SystemBankGet(z.SystemID, z.DistrTypeId) x
								WHERE z.ClientId = CL_ID 
									AND z.Complect = c.Complect
									AND z.SystemBaseName = 'CMT'
									AND InfoBankActive = 1
									AND Required = 1
									AND SystemBaseCheck = 1 AND DistrTypeBaseCheck = 1
									AND InfoBankName IN ('PKG', 'PSG', 'PPVS')
									AND	InfoBankStart <= WBEGIN
									AND NOT EXISTS
										(
											SELECT *
											FROM @ClientDIstr t
											INNER JOIN dbo.SystemBanksView q WITH(NOEXPAND) ON t.SystemID = q.SystemID
											WHERE t.ClientId = z.ClientId
												AND t.Complect = z.Complect
												AND InfoBankActive = 1 
												AND Required = 1
												AND q.SystemBaseName = 'BUD'
										)
										
								UNION
								
								SELECT ID_CLIENT = z.ClientId, InfoBankID, DISTR, COMP, InfoBankShortName, InfoBankOrder, z.SystemOrder
								FROM @ClientDistr z
								CROSS APPLY dbo.SystemBankGet(z.SystemID, z.DistrTypeId) x
								WHERE z.ClientId = CL_ID 
									AND z.Complect = c.Complect
									AND z.SystemBaseName = 'QSA'
									AND InfoBankActive = 1
									AND Required = 1
									AND SystemBaseCheck = 1 AND DistrTypeBaseCheck = 1
									AND InfoBankName IN ('PKV')
									AND	InfoBankStart <= WBEGIN
									AND NOT EXISTS
										(
											SELECT *
											FROM @ClientDIstr t
											INNER JOIN dbo.SystemBanksView q WITH(NOEXPAND) ON t.SystemID = q.SystemID
											WHERE t.ClientId = z.ClientId
												AND t.Complect = z.Complect
												AND InfoBankActive = 1 
												AND Required = 1
												AND q.SystemBaseName = 'BUD'
										)
							) AS z
						WHERE NOT EXISTS
								(
									SELECT *
									FROM @usrdata p
									WHERE UIU_DATE_S >= WBEGIN AND UIU_DATE_S <= WEND
										AND z.InfoBankID = p.InfoBankID	
										AND p.Complect = c.Complect										
										AND CL_ID = UD_ID_CLIENT
										AND UI_DISTR = DISTR
										AND UI_COMP = COMP
								)
					) AS asdasd
				ORDER BY SystemOrder, InfoBankOrder FOR XML PATH('')
			)), 1, 2, ''))				
		FROM @client c CROSS JOIN @WEEK
		WHERE NOT EXISTS
			(
				SELECT *
				FROM @skip s
				WHERE CL_ID = ClientID AND c.Complect = s.Complect AND WeekID = Week_ID
			)
		OPTION (RECOMPILE);
	
	IF OBJECT_ID('tempdb..#total') IS NOT NULL
		DROP TABLE #total

	SELECT 
		ID, ClientID, Complect, ComplectStr, CLientFullName, SystemList, ClientTypeName, ServiceType, ServiceDay, DayOrder, DayTime,
		ClientEvent, UpdateDayTime, UpdateDay, ResVersion, ConsExe, ResActual, ConsExeActual, UpdateDateTime,
		ComplianceError, REPLACE(Compliance, '&#x0A;', CHAR(10)) AS Compliance, 
		UpdateSkipError, REPLACE(UpdateSkip, '&#x0A;', CHAR(10)) AS UpdateSkip, 
		UpdateLostError,  REPLACE(UpdateLost, '&#x0A;', CHAR(10)) AS UpdateLost, 
		CASE 
			WHEN UpdateSkipError = 1 THEN 'Ќарушена' 
			ELSE NULL 
		END AS UpdatePeriod,
		UF_PATH,
		LastSTT
	INTO #total
	FROM
		(		
			SELECT DISTINCT
				ID, a.ClientID, a.Complect, a.ComplectStr, CLientFullName, SystemList, ClientTypeName, ServiceType, ServiceDay, DayOrder, DayTime,
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
							FROM @compl z
							WHERE z.ClientID = a.ClientID
								AND z.Complect= a.Complect
								AND Comp IS NOT NULL
						) THEN 1 
					ELSE 0 
				END AS ComplianceError,
				CASE
					WHEN DistrTypeBaseCheck = 0 THEN ''
					WHEN EXISTS
						(
							SELECT *
							FROM @compl z
							WHERE z.ClientID = a.ClientID
								AND z.COmplect = a.Complect
								AND Comp IS NOT NULL
						) THEN '' + 						
							(
								SELECT 
									ISNULL('с ' + CONVERT(VARCHAR(20), WBEGIN, 104) + ' по ' + CONVERT(VARCHAR(20), WEND, 104) + ': ' + Comp + CHAR(10), '')
								FROM 
									@WEEK
									INNER JOIN @compl z ON Week_ID = WeekID
								WHERE z.ClientID = a.ClientID
									AND z.Complect = a.Complect
								ORDER BY Week_ID FOR XML PATH('')							
							)
					ELSE '—овпадает'
				END AS Compliance,
				CASE
					WHEN DIstrTypeBaseCheck = 0 THEN 0
					WHEN EXISTS
						(
							SELECT *
							FROM @skip z
							WHERE z.ClientID = a.ClientID
								AND z.COmplect = a.Complect
						) THEN 1 
					ELSE 0 
				END AS UpdateSkipError,
				CASE
					WHEN DistrTypeBaseCheck = 0 THEN ''
					WHEN EXISTS
						(
							SELECT *
							FROM @skip z
							WHERE z.ClientID = a.ClientID
						) THEN '' + 						
							(
								SELECT 
									ISNULL('с ' + CONVERT(VARCHAR(20), WBEGIN, 104) + ' по ' + CONVERT(VARCHAR(20), WEND, 104) + CHAR(10), '')
								FROM 
									@WEEK INNER JOIN
									@skip z ON Week_ID = WeekID
								WHERE z.ClientID = a.ClientID
									AND z.Complect = a.Complect
								ORDER BY Week_ID FOR XML PATH('')							
							)
					ELSE ''
				END AS UpdateSkip,
				CASE
					WHEN DistrTypeBaseCheck = 0 THEN 0
					WHEN EXISTS
						(
							SELECT *
							FROM @lost z
							WHERE z.ClientID = a.ClientID
								AND z.Complect = a.Complect
								AND LostList IS NOT NULL
						) THEN 1 
					ELSE 0 
				END AS UpdateLostError,
				CASE
					WHEN DistrTypeBaseCheck = 0 THEN ''
					WHEN EXISTS
						(
							SELECT *
							FROM @lost z
							WHERE z.ClientID = a.ClientID
								AND z.Complect = a.COmplect
								AND LostList IS NOT NULL
						) THEN '' + 						
							(
								SELECT 
									ISNULL('с ' + CONVERT(VARCHAR(20), WBEGIN, 104) + ' по ' + CONVERT(VARCHAR(20), WEND, 104) + ': ' + LostList + CHAR(10), '')
								FROM 
									@WEEK INNER JOIN
									@lost z ON Week_ID = WeekID
								WHERE z.ClientID = a.ClientID
									AND z.Complect = a.COmplect
								ORDER BY Week_ID FOR XML PATH('')							
							)
					ELSE ''
				END AS UpdateLost
			FROM @res a
			LEFT JOIN @update b ON a.ClientID = b.ClientID AND a.COmplect = b.COmplect
		) AS o_O
	ORDER BY ID, ClientFullName, UpdateDateTime
	OPTION (RECOMPILE)
	
	SELECT *, (SELECT COUNT(*) FROM #total b WHERE a.ID = b.ID) AS ROW_CNT
	FROM #total a
	ORDER BY ID, ClientFullName, ComplectStr, UpdateDateTime
	
	IF OBJECT_ID('tempdb..#total') IS NOT NULL
		DROP TABLE #total
END