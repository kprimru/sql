USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[USR].[PROCESS_FILE]', 'P ') IS NULL EXEC('CREATE PROCEDURE [USR].[PROCESS_FILE]  AS SELECT 1')
GO
ALTER PROCEDURE [USR].[PROCESS_FILE]
	@t				NVarChar(Max),
	@md5			VarChar(100),
	@hash			VarChar(100),
	@filename		VarCHar(50),
	@data			VarBinary(MAX),
	@robot			TinyInt,
	@res			NVarChar(MAX)	= NULL	OUTPUT,
	@resstatus		TinyInt			= 0		OUTPUT,
	@process_date	DateTime		= NULL,
	@sessionid		VarCHar(50)		= NULL
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

		SET @t = Replace(@t, 'cons020 (1).rgt date=', 'cons020.rgt date=');
		SET @t = Replace(@t, 'CONS020(1).RGT date=', 'cons020.rgt date=');
		SET @t = Replace(@t, 'CONS020 .RGT date=', 'cons020.rgt date=');

		DECLARE
			@Xml				Xml,
			@Complect_Id		Int,
			@Complect_Active	Bit,
			@Complect_Client	Int,
			@Usr_Id				Int,
			@SystemName			VarChar(20),
			@SystemNumber		VarChar(10),
			@DistrNumber		VarChar(10),
			@CompNumber			VarChar(10),
			@System_num			VarChar(10),
			@DistrInt			Int,
			@CompInt			TinyInt,
			@ClientName			VarChar(250),
			@Client_Id			Int,
			@Manager_Id			Int,
			@Service_Id			Int,
			@ManagerName		VarChar(100),
			@ServiceName		VarChar(100);

		DECLARE @IDs TABLE
		(
			ID	Int,
			Primary Key Clustered (ID)
		);

		SET	@res = '';
		SET @resstatus = 0;

		DECLARE @Usr TABLE
		(
			ClientID				Int					NULL,
			FormatVersion			Int				NOT NULL,
			Ric						Int				NOT NULL,
			ResVersion				VarChar(50)		NOT NULL,
			ConsExeVersion			VarChar(50) 		NULL,
			KDVersion				VarChar(50) 		NULL,
			ComplectType			VarChar(64) 		NULL,
			ProcessorName			VarChar(100)		NULL,
			ProcessorFrequency		VarChar(50) 		NULL,
			ProcessorCores			VarChar(20) 		NULL,
			RAM						VarChar(20)			NULL,
			OSName					VarChar(100)	NOT NULL,
			OSVersionMinor			VarChar(20) 	NOT NULL,
			OSVersionMajor			VarChar(20) 	NOT NULL,
			OSBuild					VarChar(20) 	NOT NULL,
			OSPlatformID			VarChar(20) 	NOT NULL,
			OSEdition				VarChar(50) 		NULL,
			OSCapacity				VarChar(20) 		NULL,
			OSLangID				VarChar(50) 		NULL,
			OSCompatibility			VarChar(50) 		NULL,
			BootDiskName			VarChar(10) 		NULL,
			BootDiskFreeSpace		VarChar(20) 		NULL,
			ConsTmpDir				VarChar(256)        NULL,
			ConsTmpFree				VarCHar(20)         NULL,
			Office					VarChar(100) 		NULL,
			Browser					VarChar(100) 		NULL,
			MailAgent				VarChar(100) 		NULL,
			Rights					VarChar(50)			NULL,
			DiskFreeSpace			VarChar(20) 	NOT NULL,
			ODUsers 				VarChar(20) 	NOT NULL,
			UDUsers 				VarChar(20) 	NOT NULL,
			TSUsers 				VarChar(20) 	NOT NULL,
			VMUsers 				VarChar(20)			NULL,
			USRFileDate 			VarChar(20) 	NOT NULL,
			USRFileTime 			VarChar(20) 	NOT NULL,
			USRFileKind 			VarChar(20) 	NOT NULL,
			USRFileUptime			VarChar(20) 		NULL,
			InfoCodFileDate 		VarChar(20) 		NULL,
			InfoCodFileTime 		VarChar(20) 		NULL,
			InfoCfgFileDate 		VarChar(20) 		NULL,
			InfoCfgFileTime 		VarChar(20) 		NULL,
			ConsultTorFileDate 		VarChar(20) 		NULL,
			ConsultTorFileTime 		VarChar(20) 		NULL,
			FileSystem				VarChar(20) 		NULL,
			ExpconsDate				VarChar(20) 		NULL,
			ExpconsTime				VarChar(20) 		NULL,
			ExpconsKind 			VarChar(20) 		NULL,
			ExpusersDate			VarChar(20) 		NULL,
			ExpusersTime			VarChar(20) 		NULL,
			HotlineDate				VarChar(20) 		NULL,
			HotlineTime 			VarChar(20) 		NULL,
			HotlineKind 			VarChar(20) 		NULL,
			HotlineUsersDate 		VarChar(20) 		NULL,
			HotLineUsersTime 		VarChar(20) 		NULL,
			UserList				VarChar(20)         NULL,
			UserListOnline			VarChar(20)         NULL,
			UserListUsersOnline		VarChar(20)         NULL,
			StartKeyWorkFileDate	VarChar(20)			NULL,
			StartKeyWorkFileTime	VarChar(20)			NULL,
			StartKeyWorkFileContent	VarChar(Max)		NULL,
			StartKeyConsFileDate	VarChar(20)			NULL,
			StartKeyConsFileTime	VarChar(20)			NULL,
			StartKeyConsFileContent	VarChar(Max)		NULL,
			WineExists				VarChar(20) 		NULL,
			WineVersion 			VarChar(50) 		NULL,
			NowinName				VarChar(128) 		NULL,
			NowinExtend 			VarChar(128) 		NULL,
			NowinUnname 			VarChar(512) 		NULL,
			ResCacheUsrDate			VarChar(20) 		NULL,
			ResCacheUsrTime 		VarChar(20) 		NULL,
			ResCacheHostDate		VarChar(20) 		NULL,
			ResCacheHostTime 		VarChar(20) 		NULL,
			TimeoutCfgDate			VarChar(20) 		NULL,
			TimeoutCfgTime 			VarChar(20) 		NULL,
			ComplectCfgDate			VarChar(20) 		NULL,
			ComplectCfgTime 		VarChar(20) 		NULL,
			Rgt						Xml
		);

		DECLARE @Package TABLE
		(
			PackageName	VarChar(50)	NOT NULL,
			DistrNumber Int			NOT NULL,
			CompNumber	TinyInt		NOT NULL,
			Ric			SmallInt	NOT NULL,
			NetCount	SmallInt	NOT NULL,
			UserType	VarChar(20) NOT NULL,
			TechnolType VarChar(20) NOT NULL,
			Format		SmallInt		NULL,
			Primary Key Clustered(DistrNumber, PackageName, CompNumber)
		);

		DECLARE @Ib Table
		(
			DistrNumber		Int				NOT NULL,
			CompNumber		tinyint			NOT NULL,
			DirectoryName	VarChar(20) 	NOT NULL,
			[Name]			VarChar(150)		NULL,
			NCat			Int 				NULL,
			[NText]			Int 				NULL,
			N3 				Int 				NULL,
			N4 				Int 				NULL,
			N5 				Int 				NULL,
			N6 				Int 				NULL,
			Compliance		VarChar(20)			NULL,
			Primary Key Clustered(DistrNumber, DirectoryName, CompNumber)
		);

		DECLARE @update Table
		(
			DirectoryName	VarChar(20) NOT NULL,
			UpdateName 		VarChar(8)	NOT NULL,
			UpdateDate 		VarChar(20) 	NULL,
			UpdateTime 		VarChar(20) 	NULL,
			UpdateSysDate	VarChar(20) 	NULL,
			UpdateDocs 		Int				NULL,
			UpdateKind 		VarChar(20)		NULL,
			Primary Key Clustered(DirectoryName, UpdateName)
		);

		IF @FileName NOT LIKE 'CONS#%[_]%.usr' BEGIN
			SET @res = 'Некорректное имя файла  (' + ISNULL(@FileName, '') + ')';
			SET @resstatus = 3;

			EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;

			RETURN;
		END;

		SET @system_num = Left(Replace(@FileName, 'cons#', ''), CharIndex('_', Replace(@FileName, 'cons#', '')) - 1);

		SET @xml = CAST(@t AS XML);

		INSERT INTO @package(PackageName, DistrNumber, CompNumber, Ric, NetCount, UserType, TechnolType, Format)
		SELECT
			c.value('local-name(.)',		'VarChar(20)')	AS PackageName,
			c.value('(@distr)[1]',			'Int')			AS DistrNumber,
			c.value('(@comp)[1]',			'TinyInt')		AS CompNumber,
			c.value('(@ric)[1]',			'Int') 			AS Ric,
			c.value('(@netCount)[1]',		'Int') 			AS NetCount,
			c.value('(@userType)[1]',		'VarChar(20)') 	AS UserType,
			c.value('(@technolType)[1]',	'VarChar(20)') 	AS TechnolType,
			c.value('(@format)[1]',			'Int')			AS Format
		FROM @xml.nodes('/user_info[1]/package[1]/*') AS a(c);

		-- пытаемся определить основную систему по названию файла
		SELECT TOP 1
			@systemnumber	= RIGHT(PackageName, LEN(PackageName) - CHARINDEX('_', PackageName)),
			@systemname		= LEFT(PackageName, CHARINDEX('_', PackageName) - 1),
			@distrnumber	= Convert(Varchar(20), DistrNumber),
			@compnumber		= CompNumber
		FROM
		@Package					P
		INNER JOIN dbo.SystemTable	S ON (S.SystemBaseName + '_' + CONVERT(VARCHAR(20), S.SystemNumber)) = P.PackageName
		WHERE S.SystemNumber = @system_num;

		IF @@ROWCOUNT = 0
			SELECT TOP 1
				@systemnumber	= RIGHT(PackageName, LEN(PackageName) - CHARINDEX('_', PackageName)),
				@systemname		= LEFT(PackageName, CHARINDEX('_', PackageName) - 1),
				@distrnumber	= Convert(Varchar(20), DistrNumber),
				@compnumber		= CompNumber
			FROM
				@Package					P
				INNER JOIN dbo.SystemTable	S ON (S.SystemBaseName + '_' + CONVERT(VARCHAR(20), S.SystemNumber)) = P.PackageName
			WHERE DistrNumber <> 1
			ORDER BY
				CASE UserType
					WHEN 'NEK' THEN 1
					WHEN 'DMV' THEN 1
					ELSE 0
				END,
				CASE DistrNumber
					WHEN 1 THEN 1
					WHEN 1000 THEN 1
					WHEN 22222 THEN 1
					ELSE 0
				END,
				SystemVMI;

		SET @DistrInt	= CONVERT(Int,		@distrnumber);
		SET @CompInt	= CONVERT(TinyInt,	@compnumber);

		SELECT TOP 1
			@Complect_Id		= UD_ID,
			@Complect_Active	= UD_ACTIVE,
			@Complect_Client	= UD_ID_CLIENT
		FROM USR.USRData			C
		INNER JOIN dbo.SystemTable	S ON S.HostID = C.UD_ID_HOST
		WHERE	UD_DISTR = @DistrInt
			AND UD_COMP = @CompInt
			AND SystemNumber = @systemnumber
			AND SystemRic = 20
		ORDER BY UD_ACTIVE DESC;

		SELECT
			@Client_Id = ID_CLIENT
		FROM dbo.ClientDistrView a WITH(NOEXPAND)
		WHERE	a.DISTR = @distrint
			AND a.COMP = @compint
			AND a.SystemBaseName = @systemname;

		IF @Client_Id IS NULL
			SELECT TOP 1
				@Client_Id = ID_CLIENT
			FROM
				dbo.ClientDistrView			a WITH(NOEXPAND)
				INNER JOIN dbo.SystemTable	b ON a.SystemID = b.SystemID
				INNER JOIN @Package			c ON	c.PackageName = b.SystemBaseName + '_' + CONVERT(VARCHAR(20), b.SystemNumber)
												AND c.DistrNumber = a.DISTR
												AND c.CompNumber = a.COMP
			ORDER BY SystemNumber;

		SELECT
			@Usr_Id		= F.UF_ID
		FROM USR.USRFile			F
		INNER JOIN USR.USRFileData	D ON F.UF_ID = D.UF_ID
		WHERE	UF_MD5 = @md5
			AND UF_ID_COMPLECT = @Complect_Id
			AND UF_DATA = @data
			AND
				(
					(UF_PATH <> 3 AND @robot <> 3)
					OR
					(UF_PATH = 3 AND @robot = 3)
				);

		SELECT
			@ClientName		= ClientFullName,
			@Manager_Id		= ManagerID,
			@Service_Id		= ServiceID,
			@ManagerName	= ManagerName,
			@ServiceName	= ServiceName
		FROM dbo.ClientView WITH(NOEXPAND)
		WHERE ClientID = @Client_Id;

		IF @Usr_Id IS NOT NULL
		BEGIN
			IF	@Client_Id IS NULL
				OR
				@Complect_Client = @Client_Id
			BEGIN
				SET @res = 'Файл уже есть в базе. Пропущен. (' + ISNULL(CONVERT(VARCHAR(20), @Client_Id), 'NULL') + ')';
				SET @resstatus = 1;
			END
			ELSE
			BEGIN

				UPDATE USR.USRData
				SET UD_ID_CLIENT = @Client_Id
				WHERE UD_ID = @Complect_Id;

				SET @res = 'Файл уже есть в базе. Изменен клиент.  (' + ISNULL(CONVERT(VARCHAR(20), @Client_Id), 'NULL') + ')';
				SET @resstatus = 1;
			END;

			IF
				(
					SELECT ISNULL(UF_ID_CLIENT, 0)
					FROM USR.USRFile
					WHERE UF_ID = @Usr_Id
				) <> ISNULL(@Client_Id, 0)
				UPDATE USR.USRFile
				SET UF_ID_CLIENT	= @Client_Id,
					UF_ID_MANAGER	= @Manager_Id,
					UF_ID_SERVICE	= @Service_Id
				WHERE UF_ID = @Usr_Id;

			EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;

			RETURN;
		END;

		IF @ROBOT = 3
			AND NOT EXISTS
			(
				SELECT *
				FROM USR.USRFile
				WHERE	UF_ID_COMPLECT = @Complect_Id
					AND UF_PATH IN (1, 2)
					AND UF_CREATE >= DATEADD(MONTH, -3, GETDATE())
			)
		BEGIN
			SET @res = 'Комплект не нуждается в контроле';
			SET @resstatus = 1;

			EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;

			RETURN;
		END;

		IF @Complect_Client <> @Client_Id OR @Complect_Active = 0
		BEGIN
			IF @Complect_Client <> @Client_Id
				SET @res = @res + 'Изменен клиент'
			IF @Complect_Active = 0
				SET @res = @res + 'Изменен признак активности'

			UPDATE USR.USRData
			SET UD_ID_CLIENT	= @Client_Id,
				UD_ACTIVE		= 1
			WHERE UD_ID = @Complect_Id;
		END;

		IF @Client_Id IS NOT NULL
			SELECT @res = @res + ISNULL(@ServiceName, '') + ISNULL('(' + @ManagerName + ')', ' ') + @ClientName;

		INSERT INTO @Usr
		(
			ClientID,
			FormatVersion, Ric, ResVersion, ConsExeVersion, KDVersion, ComplectType,
			ProcessorName, ProcessorFrequency, ProcessorCores, RAM,
			OSName, OSVersionMinor, OSVersionMajor, OSBuild, OSPlatformID,
			OSEdition, OSCapacity, OSLangID, OSCompatibility,
			BootDiskName, BootDiskFreeSpace, ConsTmpDir, ConsTmpFree,
			Office, Browser, MailAgent, Rights, DiskFreeSpace,
			ODUsers, UDUsers, TSUsers, VMUsers,
			USRFileDate, USRFileTime, USRFileKind, USRFileUptime,
			InfoCodFileDate, InfoCodFileTime, InfoCfgFileDate, InfoCfgFileTime,
			ConsultTorFileDate, ConsultTorFileTime, FileSystem,
			ExpconsDate, ExpconsTime, ExpconsKind, ExpusersDate, ExpusersTime,
			HotlineDate, HotlineTime, HotlineKind, HotlineUsersDate, HotlineUsersTime,
			UserList, UserListOnline, UserListUsersOnline,
			StartKeyWorkFileDate, StartKeyWorkFileTime, StartKeyWorkFileContent,
			StartKeyConsFileDate, StartKeyConsFileTime, StartKeyConsFileContent,
			WineExists, WineVersion, NowinName, NowinExtend, NowinUnname,
			ResCacheUsrDate, ResCacheUsrTime, ResCacheHostDate, ResCacheHostTime,
			TimeoutCfgDate, TimeoutCfgTime, ComplectCfgDate, ComplectCfgTime,
			Rgt
		)
		SELECT
			@Client_Id,
			c.value('format_version[1]',							'Int') 			AS FormatVersion,
			c.value('ric[1]',										'Int')			AS Ric,
			c.value('res_version[1]',								'VarChar(20)')	AS ResVersion,
			c.value('cons_exe_version[1]',							'VarChar(20)')	AS ConsExeVersion,
			c.value('kd_version[1]',								'VarChar(20)')	AS KDVersion,
			c.value('complect[1]',									'VarChar(64)')	AS ComplectType,
			c.value('(tech_info[1]/Processors[1]/Name)[1]',			'VarChar(100)')	AS ProcessorName,
			c.value('(tech_info[1]/Processors[1]/Frequency)[1]',	'VarChar(50)')	AS ProcessorFrequency,
			c.value('(tech_info[1]/Processors[1]/AllCore)[1]',		'VarChar(20)')	AS ProcessorCores,
			c.value('(tech_info[1]/RAM)[1]',						'VarChar(20)')	AS RAM,
			c.value('(tech_info[1]/OS/Name)[1]',					'VarChar(100)')	AS OSName,
			c.value('(tech_info[1]/OS/Version/@Major)[1]',			'VarChar(20)') 	AS OSVersionMajor,
			c.value('(tech_info[1]/OS/Version/@Minor)[1]',			'VarChar(20)') 	AS OSVersionMinor,
			c.value('(tech_info[1]/OS/Build)[1]',					'VarChar(20)')	AS OSBuild,
			c.value('(tech_info[1]/OS/PlatformID)[1]',				'VarChar(20)')	AS OSPlatformID,
			c.value('(tech_info[1]/OS/Edition)[1]',					'VarChar(50)')	AS OSEdition,
			c.value('(tech_info[1]/OS/Capacity)[1]',				'VarChar(20)')	AS OSCapacity,
			c.value('(tech_info[1]/OS/LangUI)[1]',					'VarChar(50)')	AS OSLangID,
			c.value('(tech_info[1]/OS/CompatibilityMode)[1]',		'VarChar(50)')	AS OSCompatibility,
			c.value('(tech_info[1]/BootDisk/Name)[1]',				'VarChar(10)')	AS BootDiskName,
			c.value('(tech_info[1]/BootDisk/FreeSpace)[1]',			'VarChar(20)')	AS BootDiskFreeSpace,
			c.value('(tech_info[1]/ConsTmpDir/Path)[1]',			'VarChar(256)')	AS ConsTmpDir,
			c.value('(tech_info[1]/ConsTmpDir/FreeSpace)[1]',		'VarChar(20)')	AS ConsTmpFree,
			c.value('(tech_info[1]/Office)[1]',						'VarChar(100)')	AS Office,
			c.value('(tech_info[1]/Browser)[1]',					'VarChar(100)')	AS Browser,
			c.value('(tech_info[1]/MailAgent)[1]',					'VarChar(100)')	AS MailAgent,
			c.value('(tech_info[1]/Rights)[1]',						'VarChar(50)')	AS Rights,
			c.value('(tech_info[1]/DiskFreeSpace)[1]',				'VarChar(20)')	AS DiscFreeSpace,
			c.value('(tech_info[1]/Users[1]/@OD)[1]',				'VarChar(20)') 	AS ODUsers,
			c.value('(tech_info[1]/Users[1]/@UD)[1]',				'VarChar(20)') 	AS UDUsers,
			c.value('(tech_info[1]/Users[1]/@TS)[1]',				'VarChar(20)') 	AS TSUsers,
			c.value('(tech_info[1]/Users[1]/@VM)[1]',				'VarChar(20)') 	AS VMUsers,
			c.value('(files[1]/USR_FILE[1]/@date)[1]',				'VarChar(20)') 	AS USRFileDate,
			c.value('(files[1]/USR_FILE[1]/@time)[1]',				'VarChar(20)') 	AS USRFileTime,
			c.value('(files[1]/USR_FILE[1]/@kind)[1]',				'VarChar(20)') 	AS USRFileKind,
			c.value('(files[1]/USR_FILE[1]/@uptime)[1]',			'VarChar(20)')	AS USRFileUptime,

			IsNull(
			c.value('(files[1]/info.cod[1]/@date)[1]', 				'VarChar(20)'),
			c.value('(files[1]/INFO.COD[1]/@date)[1]', 				'VarChar(20)')
			) AS InfoCodFileDate,

			IsNull(
			c.value('(files[1]/info.cod[1]/@time)[1]', 				'VarChar(20)'),
			c.value('(files[1]/INFO.COD[1]/@time)[1]', 				'VarChar(20)')
			) AS InfoCodFileTime,

			Coalesce(
			c.value('(files[1]/info.cfg[1]/@date)[1]', 				'VarChar(20)'),
			c.value('(files[1]/INFO.CFG[1]/@date)[1]', 				'VarChar(20)'),
			c.value('(files[1]/INFO1.CFG[1]/@date)[1]', 			'VarChar(20)')
			) AS InfoCodFileDate,

			Coalesce(
			c.value('(files[1]/info.cfg[1]/@time)[1]', 				'VarChar(20)'),
			c.value('(files[1]/INFO.CFG[1]/@time)[1]', 				'VarChar(20)'),
			c.value('(files[1]/INFO1.CFG[1]/@time)[1]', 			'VarChar(20)')
			) AS InfoCodFileTime,

			IsNull(
			c.value('(files[1]/consult.tor[1]/@date)[1]',			'VarChar(20)'),
			c.value('(files[1]/CONSULT.TOR[1]/@date)[1]',			'VarChar(20)')
			) AS ConsultTorFileDate,

			IsNull(
			c.value('(files[1]/consult.tor[1]/@time)[1]',			'VarChar(20)'),
			c.value('(files[1]/CONSULT.TOR[1]/@time)[1]',			'VarChar(20)')
			) AS ConsultTorFileTime,

			c.value('(tech_info[1]/FileSystem)[1]',					'VarChar(20)')	AS FileSystem,

            IsNull(
			c.value('(files[1]/expcons.cfg[1]/@date)[1]', 			'VarChar(20)'),
			c.value('(files[1]/EXPCONS.CFG[1]/@date)[1]', 			'VarChar(20)')
			) AS ExpconsDate,

			IsNull(
			c.value('(files[1]/expcons.cfg[1]/@time)[1]', 			'VarChar(20)'),
			c.value('(files[1]/EXPCONS.CFG[1]/@time)[1]', 			'VarChar(20)')
			) AS ExpconsTime,

			IsNull(
			c.value('(files[1]/expcons.cfg[1]/@kind)[1]', 			'VarChar(20)'),
			c.value('(files[1]/EXPCONS.CFG[1]/@kind)[1]', 			'VarChar(20)')
			) AS ExpconsKind,

            IsNull(
			c.value('(files[1]/expusers.cfg[1]/@date)[1]', 			'VarChar(20)'),
			c.value('(files[1]/EXPUSERS.CFG[1]/@date)[1]', 			'VarChar(20)')
			) 	AS ExpusersDate,

			IsNull(
			c.value('(files[1]/expusers.cfg[1]/@time)[1]', 			'VarChar(20)'),
			c.value('(files[1]/EXPUSERS.CFG[1]/@time)[1]', 			'VarChar(20)')
			) 	AS ExpusersTime,

            IsNull(
			c.value('(files[1]/hotline.cfg[1]/@date)[1]', 			'VarChar(20)'),
			c.value('(files[1]/HOTLINE.CFG[1]/@date)[1]', 			'VarChar(20)')
			) AS HotlineDate,

			IsNull(
			c.value('(files[1]/hotline.cfg[1]/@time)[1]', 			'VarChar(20)'),
			c.value('(files[1]/HOTLINE.CFG[1]/@time)[1]', 			'VarChar(20)')
			) AS HotlineTime,

			IsNull(
			c.value('(files[1]/hotline.cfg[1]/@kind)[1]', 			'VarChar(20)'),
			c.value('(files[1]/HOTLINE.CFG[1]/@kind)[1]', 			'VarChar(20)')
			) AS HotlineKind,

            IsNull(
			c.value('(files[1]/hotlineusers.cfg[1]/@date)[1]', 		'VarChar(20)'),
			c.value('(files[1]/HOTLINEUSERS.CFG[1]/@date)[1]', 		'VarChar(20)')
			) AS HotlineUsersDate,

			IsNull(
			c.value('(files[1]/hotlineusers.cfg[1]/@time)[1]', 		'VarChar(20)'),
			c.value('(files[1]/HOTLINEUSERS.CFG[1]/@time)[1]', 		'VarChar(20)')
			) AS HotlineUsersTime,

			c.value('(userlist[1]/@userlist)[1]', 					'VarChar(20)') AS UserList,
			c.value('(userlist[1]/@online)[1]', 					'VarChar(20)') AS UserListOnline,
			c.value('(userlist[1]/@usersonline)[1]', 				'VarChar(20)') AS UserListUsersOnline,

			c.value('(files[1]/START.KEY_WORK[1]/@date)[1]',			'VarChar(20)') AS StartKeyWorkFileDate,
			c.value('(files[1]/START.KEY_WORK[1]/@time)[1]',			'VarChar(20)') AS StartKeyWorkFileTime,
			Replace(Replace(Replace(c.value('(files[1]/START.KEY_WORK[1])[1]',					'VarChar(Max)'), Char(10), ''), Char(13), ''), Char(9), '') AS StartKeyWorkContent,

			c.value('(files[1]/START.KEY_CONS[1]/@date)[1]',			'VarChar(20)') AS StartKeyConsFileDate,
			c.value('(files[1]/START.KEY_CONS[1]/@time)[1]',			'VarChar(20)') AS StartKeyConsFileTime,
			Replace(Replace(Replace(c.value('(files[1]/START.KEY_CONS[1])[1]',					'VarChar(Max)'), Char(10), ''), Char(13), ''), Char(9), '') AS StartKeyConsContent,

			c.value('(tech_info[1]/wine[1]/@exist)[1]',				'VarChar(20)')	AS WineExists,
			c.value('(tech_info[1]/wine[1]/@version)[1]',			'VarChar(20)')	AS WineExists,

			c.value('(tech_info[1]/nowin[1]/name)[1]',				'VarChar(128)')	AS NowinName,
			c.value('(tech_info[1]/nowin[1]/extend)[1]',			'VarChar(128)')	AS NowinExtend,
			c.value('(tech_info[1]/nowin[1]/uname)[1]',				'VarChar(512)')	AS NowinUnname,

			c.value('(files[1]/RESCACHE_USR_OFF[1]/@date)[1]', 		'VarChar(20)')	AS ResCacheUsrDate,
			c.value('(files[1]/RESCACHE_USR_OFF[1]/@time)[1]', 		'VarChar(20)')	AS ResCacheUsrTime,

			c.value('(files[1]/RESCACHE_HOST_ON[1]/@date)[1]', 		'VarChar(20)')	AS ResCacheHostDate,
			c.value('(files[1]/RESCACHE_HOST_ON[1]/@time)[1]', 		'VarChar(20)')	AS ResCacheHostTime,

			c.value('(files[1]/TIMEOUT.CFG[1]/@date)[1]', 			'VarChar(20)')	AS TimeoutCfgDate,
			c.value('(files[1]/TIMEOUT.CFG[1]/@time)[1]', 			'VarChar(20)')	AS TimeoutCfgTime,

			c.value('(files[1]/COMPLECT.CFG[1]/@date)[1]', 			'VarChar(20)')	AS ComplectCfgDate,
			c.value('(files[1]/COMPLECT.CFG[1]/@time)[1]', 			'VarChar(20)')	AS ComplectCfgTime,

			c.query('(files[1]/RGT[1])[1]') AS Rgt

		FROM @Xml.nodes('user_info[1]') AS a(c);

		IF (SELECT FormatVersion FROM @Usr) = '1'
		BEGIN
			SET @res = @res + 'Ошибка. Старый формат файла. Обработка прервана.';
			SET @resstatus = 3;

			EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;

			RETURN;
		END;

		IF (@ROBOT = 3)
			AND ((SELECT USRFileKind FROM @usr) <> 'K')
		BEGIN
			SET @res = 'USR-файл сформирован не по ключу';
			SET @resstatus = 1;

			EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;

			RETURN;
		END;

		UPDATE @Usr
		SET	USRFileDate = NULL
		WHERE USRFileDate = '0'
			OR USRFileDate = '00.00.0000';

		UPDATE @Usr
		SET USRFileTime = NULL
		WHERE USRFileTime = '0';

		UPDATE @Usr
		SET InfoCodFileDate = NULL
		WHERE InfoCodFileDate = '0'
			OR InfoCodFileDate = '00.00.0000';

		UPDATE @Usr
		SET InfoCodFileTime = NULL
		WHERE InfoCodFileTime = '0';

		UPDATE @Usr
		SET InfoCfgFileDate = NULL
		WHERE InfoCfgFileDate = '00.00.0000'
			OR InfoCfgFileDate = '0';

		UPDATE @Usr
		SET InfoCfgFileTime = NULL
		WHERE InfoCfgFileTime = '0';

		UPDATE @Usr
		SET ConsultTorFileDate = NULL
		WHERE ConsultTorFileDate = '0'
			OR ConsultTorFileDate = '00.00.0000';

		UPDATE @Usr
		SET ConsultTorFileTime = NULL
		WHERE ConsultTorFileTime = '0';

		UPDATE @Usr
		SET ExpconsDate = NULL
		WHERE ExpconsDate = '0'
			OR ExpconsDate = '00.00.0000';

		UPDATE @Usr
		SET ExpconsTime = NULL
		WHERE ExpconsTime = '0';

		UPDATE @Usr
		SET ExpusersDate = NULL
		WHERE ExpusersDate = '0'
			OR ExpusersDate = '00.00.0000';

		UPDATE @Usr
		SET ExpusersTime = NULL
		WHERE ExpusersTime = '0';

		UPDATE @Usr
		SET HotlineDate = NULL
		WHERE HotlineDate = '0'
			OR HotlineDate = '00.00.0000';

		UPDATE @Usr
		SET HotlineTime = NULL
		WHERE HotlineTime = '0';

		UPDATE @Usr
		SET HotlineUsersDate = NULL
		WHERE HotlineUsersDate = '0'
			OR HotlineUsersDate = '00.00.0000';

		UPDATE @Usr
		SET HotlineUsersTime = NULL
		WHERE HotlineUsersTime = '0';

		UPDATE @Usr
		SET StartKeyWorkFileDate = NULL
		WHERE StartKeyWorkFileDate = '0'
			OR StartKeyWorkFileDate = '00.00.0000';

		UPDATE @Usr
		SET StartKeyWorkFileTime = NULL
		WHERE StartKeyWorkFileTime = '0';

		UPDATE @Usr
		SET StartKeyConsFileDate = NULL
		WHERE StartKeyConsFileDate = '0'
			OR StartKeyConsFileDate = '00.00.0000';

		UPDATE @Usr
		SET StartKeyConsFileTime = NULL
		WHERE StartKeyWorkFileTime = '0';

		UPDATE @Usr
		SET ResCacheUsrDate = NULL
		WHERE ResCacheUsrDate = '0'
			OR ResCacheUsrDate = '00.00.0000';

		UPDATE @Usr
		SET ResCacheUsrTime = NULL
		WHERE ResCacheUsrTime = '0';

		UPDATE @Usr
		SET ResCacheHostDate = NULL
		WHERE ResCacheHostDate = '0'
			OR ResCacheHostDate = '00.00.0000';

		UPDATE @Usr
		SET ResCacheHostTime = NULL
		WHERE ResCacheHostTime = '0';

		UPDATE @Usr
		SET TimeoutCfgDate = NULL
		WHERE TimeoutCfgDate = '0'
			OR TimeoutCfgDate = '00.00.0000';

		UPDATE @Usr
		SET TimeoutCfgTime = NULL
		WHERE TimeoutCfgTime = '0';

		UPDATE @Usr
		SET ComplectCfgDate = NULL
		WHERE ComplectCfgDate = '0'
			OR ComplectCfgDate = '00.00.0000';

		UPDATE @Usr
		SET ComplectCfgTime = NULL
		WHERE ComplectCfgTime = '0';

		UPDATE @Usr
		SET Ric = 999
		WHERE Ric = 65535;

		IF @Client_Id IS NULL
		BEGIN
			SELECT @ClientName = Comment
			FROM Reg.RegNodeSearchView WITH(NOEXPAND)
			WHERE DistrNumber = @DISTRINT
				AND CompNumber = @COMPINT
				AND SystemBaseName = @systemname;

			IF @ClientName IS NULL
			BEGIN
				SELECT TOP 1
					@ClientName = Comment
				FROM Reg.RegNodeSearchView AS a WITH(NOEXPAND)
				INNER JOIN dbo.SystemTable b ON a.SystemBaseName = b.SystemBaseName
				INNER JOIN @package c ON	PackageName = b.SystemBaseName + '_' + CONVERT(VARCHAR(20), SystemNumber)
											AND c.DistrNumber = a.DistrNumber
											AND c.CompNumber = a.CompNumber
				ORDER BY a.SystemOrder;
			END;

			SET @res = @res + 'Предупреждение. Не найден клиент (' + ISNULL(@ClientName, '') + ')';
			SET @resstatus = 2;
		END;

		UPDATE @Usr
		SET ClientID = ISNULL(@Client_Id, 0);

		INSERT INTO @Ib(DistrNumber, CompNumber, DirectoryName, [Name], NCat, [NText], N3, N4, N5, N6, Compliance)
		SELECT DISTINCT
			c.value('(@nDistr)[1]',		'Int')			AS DistrNumber,
			c.value('(@nComp)[1]',		'TinyInt')		AS CompNumber,
			c.value('(@directory)[1]',	'VarChar(20)')	AS DirectoryName,
			c.value('(@name)[1]',		'VarChar(150)') AS [Name],
			c.value('(@nCat)[1]',		'Int') 			AS NCat,
			c.value('(@nTexts)[1]', 	'Int') 			AS [NText],
			c.value('(@n3)[1]', 		'Int') 			AS N3,
			c.value('(@n4)[1]', 		'Int') 			AS N4,
			c.value('(@n5)[1]', 		'Int') 			AS N5,
			c.value('(@n6)[1]', 		'Int') 			AS N6,
			c.value('(@compliance)[1]',	'VarChar(20)')	AS Compliance
		FROM @xml.nodes('/user_info[1]/ib[1]/*') AS a(c);

		DELETE FROM @Ib WHERE DistrNumber IS NULL;

		/*DELETE FROM #ib WHERE DirectoryName IN ('CMT', 'RLAW104', 'RLAW947', 'RLAW968')*/

		DELETE FROM @Ib WHERE DirectoryName IN ('SVR017', 'SVBA072', 'SVR902');

		DELETE FROM @Package WHERE PackageName IN ('SVR017_112', 'SVBA072_102', 'SVR902_112');

		INSERT INTO @Update(DirectoryName, UpdateName, UpdateDate, UpdateTime, UpdateSysDate, UpdateDocs, UpdateKind)
		SELECT DISTINCT
			DirectoryName, UpdateName, UpdateDate, UpdateTime, UpdateSysDate,
			CASE
				WHEN UpdateDocs > 2000000000 THEN 2000000000
				ELSE CONVERT(Int, UpdateDocs)
			END,
			UpdateKind
		FROM
		(
			SELECT
				c.value('local-name(../..)',	'VarChar(20)') 	AS DirectoryName,
				c.value('local-name(.)',		'VarChar(20)') 	AS UpdateName,
				c.value('(@date)[1]', 			'VarChar(20)') 	AS UpdateDate,
				c.value('(@time)[1]', 			'VarChar(20)') 	AS UpdateTime,
				c.value('(@sysdate)[1]',		'VarChar(20)') 	AS UpdateSysDate,
				c.value('(@docs)[1]',			'BigInt')		AS UpdateDocs,
				c.value('(@kind)[1]',			'VarChar(20)')	AS UpdateKind
			FROM @xml.nodes('/user_info[1]/ib[1]/*/updates/*') AS a(c)
		) AS o_O;

		UPDATE @Update
		SET UpdateSysDate = NULL
		WHERE UpdateSysDate = '0';

		UPDATE @Update
		SET UpdateDate = NULL
		WHERE UpdateDate = '0';

		UPDATE @Update
		SET UpdateTime = '00:00'
		WHERE UpdateTime = '0';

		DELETE FROM @Update
		WHERE UpdateDate IS NULL
			OR UpdateTime IS NULL
			OR UpdateSysDate IS NULL;

		IF NOT EXISTS(SELECT * FROM @Update)
		BEGIN
			SET @res = @res + 'Предупреждение. Отсутствует информация о пополнении. ';
			SET @resstatus = 2;
		END

		IF EXISTS
			(
				SELECT *
				FROM @Package
				WHERE NOT EXISTS
					(
						SELECT *
						FROM dbo.SystemTable
						WHERE SystemBaseName = LEFT(PackageName, CHARINDEX('_', PackageName) - 1)
							AND SystemNumber = RIGHT(PackageName, LEN(PackageName) - CHARINDEX('_', PackageName))
					)
			)
		BEGIN
			SET @res = @res + ' Неизвестная система: ';

			SELECT @res = @res + PackageName + ' '
			FROM @package
			WHERE NOT EXISTS
				(
					SELECT *
					FROM dbo.SystemTable
					WHERE SystemBaseName = LEFT(PackageName, CHARINDEX('_', PackageName) - 1)
						AND SystemNumber = RIGHT(PackageName, LEN(PackageName) - CHARINDEX('_', PackageName))
				);

			SET @resstatus = 3;

			EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;

			RETURN;
		END;

		IF EXISTS
			(
				SELECT *
				FROM @Ib
				WHERE NOT EXISTS
					(
						SELECT *
						FROM dbo.InfoBankTable
						WHERE InfoBankName = DirectoryName

					)
			)
		BEGIN
			SET @res = @res + ' Неизвестный информационный банк: ';

			SELECT @res = @res + DirectoryName + ' '
			FROM @ib
			WHERE NOT EXISTS
				(
						SELECT *
						FROM dbo.InfoBankTable
						WHERE InfoBankName = DirectoryName

				);

			SET @resstatus = 3;

			EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;

			RETURN;
		END;

		IF @Complect_Id IS NULL
		BEGIN
			INSERT INTO USR.USRData(UD_ID_CLIENT, UD_ACTIVE, UD_ID_HOST, UD_DISTR, UD_COMP)
			OUTPUT INSERTED.UD_ID INTO @IDs (ID)
			SELECT TOP 1 @Client_Id, 1, HostID, @DISTRINT, @COMPINT
			FROM dbo.SystemTable S
			WHERE S.SystemNumber = @systemnumber;

			SELECT @Complect_Id = ID
			FROM @IDs;

			DELETE FROM @IDs;
		END
		ELSE
		BEGIN
			IF @Client_Id IS NOT NULL AND
				(
					SELECT UD_ID_CLIENT
					FROM USR.USRData
					WHERE UD_ID = @Complect_Id
				) <> @Client_Id
				UPDATE USR.USRData
				SET UD_ID_CLIENT = @Client_Id
				WHERE UD_ID = @Complect_Id;
		END;

		IF NOT EXISTS
			(
				SELECT *
				FROM dbo.ResVersionTable
				INNER JOIN @Usr ON ResVersionNumber = ResVersion
			)
		BEGIN
			INSERT INTO dbo.ResVersionTable(ResVersionNumber, ResVersionShort, IsLatest)
			SELECT ResVersion, LEFT(ResVersion, LEN(ResVersion) - CHARINDEX('.', REVERSE(ResVersion))), 0
			FROM @Usr;
		END;

		IF NOT EXISTS
			(
				SELECT *
				FROM dbo.ConsExeVersionTable
				INNER JOIN @Usr ON ConsExeVersionName = ConsExeVersion
			)
		BEGIN
			INSERT INTO dbo.ConsExeVersionTable(ConsExeVersionName, ConsExeVersionActive)
			SELECT ConsExeVersion, 0
			FROM @Usr
			WHERE ConsExeVersion IS NOT NULL;
		END;

		IF NOT EXISTS
			(
				SELECT *
				FROM dbo.KDVersion
				INNER JOIN @Usr ON KDVersion = NAME
			)
		BEGIN
			INSERT INTO dbo.KDVersion(NAME, SHORT, ACTIVE)
			SELECT KDVersion, LEFT(KDVersion, LEN(KDVersion) - CHARINDEX('.', REVERSE(KDVersion))), 0
			FROM @Usr
			WHERE KDVersion IS NOT NULL;
		END;

		IF NOT EXISTS
			(
				SELECT *
				FROM
					USR.Os
					INNER JOIN @Usr ON ISNULL(OSName, '') = ISNULL(OS_NAME, '')
						AND ISNULL(OSVersionMinor, '') = ISNULL(OS_MIN, 0)
						AND ISNULL(OSVersionMajor, '') = ISNULL(OS_MAJ, 0)
						AND ISNULL(OSBuild, '') = ISNULL(OS_BUILD, 0)
						AND ISNULL(OSPlatformID, '') = ISNULL(OS_PLATFORM, 0)
						AND ISNULL(OSEdition, '') = ISNULL(OS_EDITION, '')
						AND ISNULL(OSCapacity, '') = ISNULL(OS_CAPACITY, '')
						AND ISNULL(OSLangID, '') = ISNULL(OS_LANG, '')
						AND ISNULL(OSCompatibility, '') = ISNULL(OS_COMPATIBILITY, '')
			)
		BEGIN
			INSERT INTO USR.Os
				(
					OS_NAME, OS_MIN, OS_MAJ, OS_BUILD, OS_PLATFORM,
					OS_EDITION, OS_CAPACITY, OS_LANG, OS_COMPATIBILITY
				)
			SELECT
				ISNULL(OSName, ''), ISNULL(OSVersionMinor, 0), ISNULL(OSVersionMajor, 0), ISNULL(OSBuild, 0),
				ISNULL(OSPlatformID, 0), ISNULL(OSEdition, ''), ISNULL(OSCapacity, ''),
				ISNULL(OSLangID, ''), ISNULL(OSCompatibility, '')
			FROM @Usr;
		END;

		IF NOT EXISTS
			(
				SELECT *
				FROM USR.Processor
				INNER JOIN @Usr ON ProcessorName = PRC_NAME
						AND ProcessorFrequency = PRC_FREQ_S
						AND ProcessorCores = PRC_CORE
			)
			INSERT INTO USR.Processor(PRC_NAME, PRC_FREQ_S, PRC_FREQ, PRC_CORE)
				SELECT
					ProcessorName, ProcessorFrequency,
					CASE CHARINDEX('GHz', ProcessorFrequency)
						WHEN 0 THEN
							CASE CHARINDEX('MHz', ProcessorFrequency)
								WHEN 0 THEN 0
								ELSE CONVERT(DECIMAL(8, 4), RTRIM(LEFT(ProcessorFrequency, CHARINDEX('MHz', ProcessorFrequency) - 1)) / 1000.0)
							END
						ELSE CONVERT(DECIMAL(8, 4), RTRIM(LEFT(ProcessorFrequency, CHARINDEX('GHz', ProcessorFrequency) - 1)))
					END,
					ProcessorCores
				FROM @Usr
				WHERE ProcessorName IS NOT NULL
					AND ProcessorCores IS NOT NULL
					AND ProcessorFrequency IS NOT NULL;

		IF NOT EXISTS
			(
				SELECT *
				FROM dbo.USRFileKindTable
				INNER JOIN
				(
					SELECT USRFileKind
					FROM @Usr

					UNION ALL

					SELECT UpdateKind
					FROM @Update
				) AS t ON USRFileKind = USRFileKindName
			)
		BEGIN
			INSERT INTO dbo.USRFileKindTable(USRFileKindName, USRFileKindShortName)
			SELECT USRFileKind, ''
			FROM
			(
				SELECT USRFileKind
				FROM @Usr

				UNION ALL

				SELECT UpdateKind
				FROM @Update
			) AS o_O
			WHERE NOT EXISTS
				(
					SELECT *
					FROM dbo.USRFileKindTable
					WHERE USRFileKindName = USRFileKind
				);
		END

		IF NOT EXISTS
			(
				SELECT *
				FROM @Ib
				INNER JOIN dbo.ComplianceTypeTable ON ComplianceTypeName = Compliance
			)
		BEGIN
			INSERT INTO dbo.ComplianceTypeTable(ComplianceTypeName, ComplianceTypeShortName, ComplianceTypeOrder)
			SELECT Compliance, '', 0
			FROM @Ib
			WHERE NOT EXISTS
			(
				SELECT *
				FROM dbo.ComplianceTypeTable
				WHERE ComplianceTypeName = Compliance
			);
		END;

		INSERT INTO USR.USRFile
			(
				UF_ID_COMPLECT, UF_PATH, UF_MD5, UF_HASH, UF_NAME, UF_DATE, UF_ID_KIND,
				UF_UPTIME, UF_CREATE, UF_USER, UF_ACTIVE, UF_MIN_DATE, UF_MAX_DATE,
				UF_COMPLIANCE, UF_ID_CLIENT, UF_ID_MANAGER, UF_ID_SERVICE, UF_SESSION,
				UF_ID_SYSTEM, UF_DISTR, UF_COMP
			)
		OUTPUT INSERTED.UF_ID INTO @IDs(ID)
		SELECT
			@Complect_Id, @robot, @md5, @hash, @filename,
			CONVERT(DATETIME,
				LEFT(CONVERT(VARCHAR(50), CONVERT(DATETIME, USRFileDate, 104), 121), 10) + ' ' +
				SUBSTRING(USRFileTime, 1, 2) + ':' + SUBSTRING(USRFileTime, 4, 2) + ':00.000',
				121
			),
			USRFileKindID, USRFileUptime,
			GETDATE(), ORIGINAL_LOGIN(),
			CASE
				WHEN CONVERT(DATETIME,
					LEFT(CONVERT(VARCHAR(50), CONVERT(DATETIME, USRFileDate, 104), 121), 10) + ' ' +
					SUBSTRING(USRFileTime, 1, 2) + ':' + SUBSTRING(USRFileTime, 4, 2) + ':00.000',
					121
				) > DATEADD(HOUR, 2, GETDATE()) THEN 0
				ELSE 1
			END,
			(
				SELECT MIN(CONVERT(SMALLDATETIME, UpdateDate, 104))
				FROM @Update
			),
			(
				SELECT MAX(CONVERT(SMALLDATETIME, UpdateDate, 104))
				FROM @Update
			),
			(
				SELECT TOP 1 ComplianceTypeName
				FROM dbo.ComplianceTypeTable
				INNER JOIN @ib ON ComplianceTypeName = Compliance
				WHERE DistrNumber <> 1
				ORDER BY ComplianceTypeOrder DESC
			), @Client_Id, @Manager_Id, @Service_Id, @sessionid,
			SystemID, DistrNumber, CompNumber
		FROM @Usr
		INNER JOIN dbo.USRFileKindTable ON USRFileKindName = USRFileKind
		CROSS APPLY
		(
			SELECT TOP 1 SystemID, DistrNumber, CompNumber
			FROM @Package
			INNER JOIN dbo.SystemTable ON (SystemBaseName + '_' + CONVERT(VARCHAR(20), SystemNumber)) = PackageName
			WHERE SystemNumber = @SystemNumber
		) AS S;

		SELECT @Usr_Id = ID
		FROM @IDs;

		DELETE FROM @IDs;

		INSERT INTO USR.USRFileTech(
						UF_ID, UF_FORMAT, UF_RIC, UF_ID_RES, UF_ID_CONS, UF_ID_KDVERSION,
						UF_ID_PROC, UF_RAM, UF_ID_OS, UF_BOOT_NAME, UF_BOOT_FREE, UF_CONS_FREE,
						UF_OFFICE, UF_BROWSER, UF_MAIL, UF_RIGHT, UF_OD, UF_UD, UF_TS, UF_VM,
						UF_INFO_COD, UF_INFO_CFG, UF_CONSULT_TOR, UF_FILE_SYSTEM, UF_EXPCONS,
						UF_EXPCONS_KIND, UF_EXPUSERS, UF_HOTLINE, UF_HOTLINE_KIND, UF_HOTLINEUSERS,
						UF_USERLIST, UF_USERLISTONLINE, UF_USERLISTUSERSONLINE,
						UF_START_KEY_WORK_DATE, UF_START_KEY_WORK_CONTENT,
						UF_START_KEY_CONS_DATE, UF_START_KEY_CONS_CONTENT,
						UF_WINE_EXISTS, UF_WINE_VERSION, UF_NOWIN_NAME, UF_NOWIN_EXTEND,
						UF_NOWIN_UNNAME, UF_COMPLECT_TYPE, UF_TEMP_DIR, UF_TEMP_FREE,
						UF_RESCACHE_USR_OFF_DATE, UF_RESCACHE_HOST_ON_DATE,
						UF_TIMEOUT_CFG_DATE, UF_COMPLECT_CFG_DATE,
						UF_RGT
						)
		SELECT
			@Usr_Id, FormatVersion, Ric, ResVersionID, ConsExeVersionID, ID,
			(
				SELECT TOP 1 PRC_ID
				FROM USR.Processor
				WHERE PRC_NAME = ProcessorName
					AND PRC_FREQ_S = ProcessorFrequency
					AND PRC_CORE = ProcessorCores
			), RAM,
			(
				SELECT OS_ID
				FROM USR.Os
				WHERE ISNULL(OSName, '') = ISNULL(OS_NAME, '')
					AND ISNULL(OSVersionMinor, '') = ISNULL(OS_MIN, 0)
					AND ISNULL(OSVersionMajor, '') = ISNULL(OS_MAJ, 0)
					AND ISNULL(OSBuild, '') = ISNULL(OS_BUILD, 0)
					AND ISNULL(OSPlatformID, '') = ISNULL(OS_PLATFORM, 0)
					AND ISNULL(OSEdition, '') = ISNULL(OS_EDITION, '')
					AND ISNULL(OSCapacity, '') = ISNULL(OS_CAPACITY, '')
					AND ISNULL(OSLangID, '') = ISNULL(OS_LANG, '')
					AND ISNULL(OSCompatibility, '') = ISNULL(OS_COMPATIBILITY, '')
			), BootDiskName, BootDiskFreeSpace, DiskFreeSpace,
			Office, Browser, MailAgent, Rights, ODUsers, UDUsers, TSUsers, VMUsers,
			CONVERT(DATETIME,
				LEFT(CONVERT(VARCHAR(50), CONVERT(DATETIME, InfoCodFileDate, 104), 121), 10) + ' ' +
				SUBSTRING(InfoCodFileTime, 1, 2) + ':' + SUBSTRING(InfoCodFileTime, 4, 2) + ':00.000',
				121
			),
			CONVERT(DATETIME,
				LEFT(CONVERT(VARCHAR(50), CONVERT(DATETIME, InfoCfgFileDate, 104), 121), 10) + ' ' +
				SUBSTRING(InfoCfgFileTime, 1, 2) + ':' + SUBSTRING(InfoCfgFileTime, 4, 2) + ':00.000',
				121
			),
			CONVERT(DATETIME,
				LEFT(CONVERT(VARCHAR(50), CONVERT(DATETIME, ConsultTorFileDate, 104), 121), 10) + ' ' +
				SUBSTRING(ConsultTorFileTime, 1, 2) + ':' + SUBSTRING(ConsultTorFileTime, 4, 2) + ':00.000',
				121
			),
			FileSystem,
			CONVERT(DATETIME,
				LEFT(CONVERT(VARCHAR(50), CONVERT(DATETIME, ExpconsDate, 104), 121), 10) + ' ' +
				SUBSTRING(ExpconsTime, 1, 2) + ':' + SUBSTRING(ExpconsTime, 4, 2) + ':00.000',
				121
			),
			ExpconsKind,
			CONVERT(DATETIME,
				LEFT(CONVERT(VARCHAR(50), CONVERT(DATETIME, ExpusersDate, 104), 121), 10) + ' ' +
				SUBSTRING(ExpusersTime, 1, 2) + ':' + SUBSTRING(ExpusersTime, 4, 2) + ':00.000',
				121
			),
			CONVERT(DATETIME,
				LEFT(CONVERT(VARCHAR(50), CONVERT(DATETIME, HotlineDate, 104), 121), 10) + ' ' +
				SUBSTRING(HotlineTime, 1, 2) + ':' + SUBSTRING(HotlineTime, 4, 2) + ':00.000',
				121
			),
			HotlineKind,
			CONVERT(DATETIME,
				LEFT(CONVERT(VARCHAR(50), CONVERT(DATETIME, HotlineUsersDate, 104), 121), 10) + ' ' +
				SUBSTRING(HotlineUsersTime, 1, 2) + ':' + SUBSTRING(HotlineUsersTime, 4, 2) + ':00.000',
				121
			),
            Cast(UserList AS Bit), Cast(UserListOnline AS Bit), Cast(UserListUsersOnline AS SmallInt),
			CONVERT(DATETIME,
				LEFT(CONVERT(VARCHAR(50), CONVERT(DATETIME, StartKeyWorkFileDate, 104), 121), 10) + ' ' +
				SUBSTRING(StartKeyWorkFileTime, 1, 2) + ':' + SUBSTRING(StartKeyWorkFileTime, 4, 2) + ':00.000',
				121
			),
			StartKeyWorkFileContent,
			CONVERT(DATETIME,
				LEFT(CONVERT(VARCHAR(50), CONVERT(DATETIME, StartKeyConsFileDate, 104), 121), 10) + ' ' +
				SUBSTRING(StartKeyConsFileTime, 1, 2) + ':' + SUBSTRING(StartKeyConsFileTime, 4, 2) + ':00.000',
				121
			),
			StartKeyConsFileContent,
			WineExists, WineVersion, NowinName, NowinExtend, NowinUnname, ComplectType, ConsTmpDir, ConsTmpFree,
			CONVERT(DATETIME,
				LEFT(CONVERT(VARCHAR(50), CONVERT(DATETIME, ResCacheUsrDate, 104), 121), 10) + ' ' +
				SUBSTRING(ResCacheUsrTime, 1, 2) + ':' + SUBSTRING(ResCacheUsrTime, 4, 2) + ':00.000',
				121
			),
			CONVERT(DATETIME,
				LEFT(CONVERT(VARCHAR(50), CONVERT(DATETIME, ResCacheHostDate, 104), 121), 10) + ' ' +
				SUBSTRING(ResCacheHostTime, 1, 2) + ':' + SUBSTRING(ResCacheHostTime, 4, 2) + ':00.000',
				121
			),
			CONVERT(DATETIME,
				LEFT(CONVERT(VARCHAR(50), CONVERT(DATETIME, TimeoutCfgDate, 104), 121), 10) + ' ' +
				SUBSTRING(TimeoutCfgTime, 1, 2) + ':' + SUBSTRING(TimeoutCfgTime, 4, 2) + ':00.000',
				121
			),
			CONVERT(DATETIME,
				LEFT(CONVERT(VARCHAR(50), CONVERT(DATETIME, ComplectCfgDate, 104), 121), 10) + ' ' +
				SUBSTRING(ComplectCfgTime, 1, 2) + ':' + SUBSTRING(ComplectCfgTime, 4, 2) + ':00.000',
				121
			),
			Rgt
		FROM @Usr
		INNER JOIN dbo.ResVersionTable		ON ResVersionNumber = ResVersion
		INNER JOIN dbo.ConsExeVersionTable	ON ConsExeVersionName = ConsExeVersion
		LEFT JOIN dbo.KDVersion				ON KDVersion = NAME;

		INSERT INTO USR.USRFileData(UF_ID, UF_DATA)
		VALUES(@Usr_Id, @data);

		INSERT INTO USR.USRPackage
			(
				UP_ID_USR,
				UP_ID_SYSTEM, UP_DISTR, UP_COMP,
				UP_RIC, UP_NET, UP_TECH, UP_TYPE, UP_FORMAT
			)
		SELECT
			@Usr_Id, SystemID,
			DistrNumber, CompNumber,
			Ric, NetCount, TechnolType, UserType, Format
		FROM @Package a
		INNER JOIN dbo.SystemTable ON SystemBaseName = LEFT(PackageName, CHARINDEX('_', PackageName) - 1)
									AND SystemNumber = RIGHT(PackageName, LEN(PackageName) - CHARINDEX('_', PackageName));

		INSERT INTO USR.USRIB
			   (
					UI_ID_USR,
					UI_ID_BASE, UI_DISTR, UI_COMP,
					UI_NCAT, UI_NTEXT, UI_N3, UI_N4, UI_N5, UI_N6,
					UI_ID_COMP
				)
		SELECT
			@Usr_Id, b.InfoBankId, DistrNumber, CompNumber,
			NCat, [NText], N3, N4, N5, N6,
			ComplianceTypeID
		FROM @ib a
		INNER JOIN dbo.InfoBankTable b		ON InfoBankName = DirectoryName
		INNER JOIN dbo.ComplianceTypeTable	ON ComplianceTypeName = Compliance;

		INSERT INTO USR.USRUpdates
			(
				UIU_ID_IB, UIU_DATE, UIU_SYS, UIU_DOCS, UIU_ID_KIND, UIU_INDX
			)
		SELECT
			UI_ID,
			CONVERT(DATETIME,
					LEFT(CONVERT(VARCHAR(50), CONVERT(DATETIME, UpdateDate, 104), 121), 10) + ' ' +
					SUBSTRING(UpdateTime, 1, 2) + ':' + SUBSTRING(UpdateTime, 4, 2) + ':00.000',
					121
				),
			CONVERT(SMALLDATETIME, UpdateSysDate, 104), UpdateDocs,
			USRFileKindID, Cast(Replace(UpdateName, 'u', '') AS TinyInt)
		FROM @Update a
		INNER JOIN dbo.USRFileKindTable ON USRFileKindName = UpdateKind
		INNER JOIN dbo.InfoBankTable	ON InfoBankName = DirectoryName
		INNER JOIN USR.USRIB b			ON InfoBankID = UI_ID_BASE AND UI_ID_USR = @Usr_Id;

		UPDATE USR.USRIB
		SET UI_LAST =
			(
				SELECT UIU_DATE
				FROM USR.USRUpdates
				WHERE UIU_ID_IB = UI_ID
					AND UIU_INDX = 1
			)
		WHERE UI_ID_USR = @Usr_Id;

        EXEC [USR].[USR_ACTIVE_CACHE_REBUILD] @UD_ID = @Complect_Id;

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [USR].[PROCESS_FILE] TO rl_usr_process;
GO
