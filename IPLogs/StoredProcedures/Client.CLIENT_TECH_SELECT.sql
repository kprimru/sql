USE [IPLogs]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [Client].[CLIENT_TECH_SELECT]
	@CLIENT	INT,
	@CLIENT_TYPE	NVARCHAR(20) = NULL
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

	    IF OBJECT_ID('tempdb..#tech')	 IS NOT NULL
		    DROP TABLE #tech

	    DECLARE @tech VARCHAR(50)
	    DECLARE @cons VARCHAR(50)
	    DECLARE @complect VARCHAR(50)
	    DECLARE @system VARCHAR(50)

	    SET @tech = 'Тех.информация'
	    SET @cons = 'К+ информация'
	    SET @complect = 'Комплект'
	    SET @system = 'Системы'
    
	    IF OBJECT_ID('tempdb..#usr') IS NOT NULL
		    DROP TABLE #usr

	    CREATE TABLE #usr
		    (
			    ClientBaseID INT,
			    ComplectNumber VARCHAR(50),
			    FormatVersion INT,
			    Ric INT,
			    ResVersion  VARCHAR(50),
			    ConsExeVersion VARCHAR(20),
			    ProcessorName VARCHAR(100),
			    ProcessorFrequency VARCHAR(50),
			    ProcessorCores VARCHAR(20),
			    RAM VARCHAR(20),
			    OSName VARCHAR(150),
			    OSVersionMinor VARCHAR(20),
			    OSVersionMajor VARCHAR(20),
			    OSBuild VARCHAR(20),
			    OSPlatformID VARCHAR(20),
			    OSEdition VARCHAR(50),
			    OSCapacity VARCHAR(20),
			    OSLangID VARCHAR(50),
			    OSCompatibility VARCHAR(50),
			    BootDiskName VARCHAR(10),
			    BootDiskFreeSpace VARCHAR(20),
			    Office VARCHAR(100),
			    Browser VARCHAR(100),
			    MailAgent VARCHAR(100),
			    Rights VARCHAR(50),
			    DiskFreeSpace VARCHAR(20),
			    ODUsers VARCHAR(20),
			    UDUsers VARCHAR(20),
			    TSUsers VARCHAR(20),
			    VMUsers VARCHAR(20),
			    USRFileDate VARCHAR(20),
			    USRFileTime VARCHAR(20),
			    USRFileKind VARCHAR(20),
			    USRFileUptime VARCHAR(20),
			    InfoCodFileDate VARCHAR(20),
			    InfoCodFileTime VARCHAR(20),
			    InfoCfgFileDate VARCHAR(20),
			    InfoCfgFileTime VARCHAR(20),
			    ConsultTorFileDate VARCHAR(20),
			    ConsultTorFileTime VARCHAR(20),
		    CONSTRAINT [PK_TMP_USR] PRIMARY KEY NONCLUSTERED
			    (
				    [ClientBaseID] ASC
			    )
			    WITH
				    (
					    PAD_INDEX  = OFF,
					    STATISTICS_NORECOMPUTE  = OFF,
					    IGNORE_DUP_KEY = OFF,
					    ALLOW_ROW_LOCKS  = ON,
					    ALLOW_PAGE_LOCKS  = ON
				    ) ON [PRIMARY]
		    ) ON [PRIMARY]

	    IF @CLIENT_TYPE = 'OIS'
		    INSERT INTO #usr
			    (
				    ClientBaseID, ComplectNumber, FormatVersion, Ric, ResVersion, ConsExeVersion,
				    ProcessorName, ProcessorFrequency, ProcessorCores, RAM,
				    OSName, OSVersionMinor, OSVersionMajor, OSBuild, OSPlatformID,
				    OSEdition, OSCapacity, OSLangID, OSCompatibility,
				    BootDiskName, BootDiskFreeSpace, DiskFreeSpace,
				    Office, Browser, MailAgent, Rights,
				    ODUsers, UDUsers, TSUsers, VMUsers,
				    USRFileDate, USRFileTime, USRFileKind, USRFileUptime,
				    InfoCodFileDate, InfoCodFileTime, InfoCfgFileDate, InfoCfgFileTime,
				    ConsultTorFileDate, ConsultTorFileTime
			    )
			    SELECT
				    ClientBaseID, ComplectNumber, FormatVersion, Ric, ResVersion, ConsExeVersion,
				    ProcessorName, ProcessorFrequency, ProcessorCores, RAM,
				    OSName, OSVersionMinor, OSVersionMajor, OSBuild, OSPlatformID,
				    OSEdition, OSCapacity, OSLangID, OSCompatibility,
				    BootDiskName, BootDiskFreeSpace, DiskFreeSpace,
				    Office, Browser, MailAgent, Rights,
				    ODUsers, UDUsers, TSUsers, VMUsers,
				    USRFileDate, USRFileTime, USRFileKind, USRFileUptime,
				    InfoCodFileDate, InfoCodFileTime, InfoCfgFileDate, InfoCfgFileTime,
				    ConsultTorFileDate, ConsultTorFileTime
			    FROM ClientDB.dbo.USRTable
			    WHERE ClientID = @CLIENT
				    AND ComplectNumber <> '0'
			    ORDER BY USRFileDate DESC, USRFileTime DESC
	    ELSE IF @CLIENT_TYPE = 'DBF'
		    INSERT INTO #usr
			    (
				    ClientBaseID, ComplectNumber, FormatVersion, Ric, ResVersion, ConsExeVersion,
				    ProcessorName, ProcessorFrequency, ProcessorCores, RAM,
				    OSName, OSVersionMinor, OSVersionMajor, OSBuild, OSPlatformID,
				    OSEdition, OSCapacity, OSLangID, OSCompatibility,
				    BootDiskName, BootDiskFreeSpace, DiskFreeSpace,
				    Office, Browser, MailAgent, Rights,
				    ODUsers, UDUsers, TSUsers, VMUsers,
				    USRFileDate, USRFileTime, USRFileKind, USRFileUptime,
				    InfoCodFileDate, InfoCodFileTime, InfoCfgFileDate, InfoCfgFileTime,
				    ConsultTorFileDate, ConsultTorFileTime
			    )
			    SELECT
				    ClientBaseID, ComplectNumber, FormatVersion, Ric, ResVersion, ConsExeVersion,
				    ProcessorName, ProcessorFrequency, ProcessorCores, RAM,
				    OSName, OSVersionMinor, OSVersionMajor, OSBuild, OSPlatformID,
				    OSEdition, OSCapacity, OSLangID, OSCompatibility,
				    BootDiskName, BootDiskFreeSpace, DiskFreeSpace,
				    Office, Browser, MailAgent, Rights,
				    ODUsers, UDUsers, TSUsers, VMUsers,
				    USRFileDate, USRFileTime, USRFileKind, USRFileUptime,
				    InfoCodFileDate, InfoCodFileTime, InfoCfgFileDate, InfoCfgFileTime,
				    ConsultTorFileDate, ConsultTorFileTime
			    FROM ClientDB.dbo.USRTable a
			    WHERE EXISTS
				    (
					    SELECT *
					    FROM
						    ClientDB.dbo.USRPackageTable b INNER JOIN
						    ClientDB.dbo.SystemTable c ON c.SystemBaseName = LEFT(PackageName, CHARINDEX('_', PackageName) - 1) INNER JOIN
						    [PC275-SQL\DELTA].DBF.dbo.DistrView d ON
											    b.DistrNumber = d.DIS_NUM
										    AND b.CompNumber = d.DIS_COMP_NUM
										    AND SystemBaseName = SYS_REG_NAME INNER JOIN
						    [PC275-SQL\DELTA].DBF.dbo.TODistrTable e ON TD_ID_DISTR = DIS_ID
					    WHERE a.CLientBaseID = b.ClientBaseID
						    AND TD_ID_TO = @CLIENT
				    ) AND ComplectNumber <> '0'
			    ORDER BY USRFileDate DESC, USRFileTime DESC
    

	    CREATE TABLE #tech
		    (
			    ID	INT IDENTITY(1, 1) PRIMARY KEY,
			    MASTER_ID INT,
			    USR_ID	INT,
			    PACKAGE_ID	INT,
			    BASE_ID	INT,
			    NAME_DATA	VARCHAR(500),
			    VALUE_DATA	VARCHAR(1000),
			    STAT SMALLINT DEFAULT 0
		    )

	    INSERT INTO #tech(MASTER_ID, USR_ID, NAME_DATA, VALUE_DATA, STAT)
		    SELECT NULL,  ClientBaseID, @complect, ComplectNumber + ' ' USRFileDate,
			    CASE
				    WHEN EXISTS
					    (
						    SELECT *
						    FROM ClientDB.dbo.USRIBTable b
						    WHERE a.ClientBaseID = b.ClientBaseID
							    AND Compliance = '#HOST'
							    AND DistrNumber <> 1
					    ) THEN 2
				    ELSE 1
			    END
		    FROM #usr a

	    INSERT INTO #tech(MASTER_ID, USR_ID, NAME_DATA, VALUE_DATA, STAT)
		    SELECT
			    (
				    SELECT ID
				    FROM #tech
				    WHERE USR_ID = a.ClientBaseID
					    AND NAME_DATA = @complect
			    ), CLientBaseID, @tech, '', 3
		    FROM #usr a

	    INSERT INTO #tech(MASTER_ID, USR_ID, NAME_DATA, VALUE_DATA, STAT)
		    SELECT
			    (
				    SELECT ID
				    FROM #tech
				    WHERE USR_ID = a.ClientBaseID
					    AND NAME_DATA = @complect
			    ), ClientBaseID, @cons, '', 3
		    FROM #usr a



	    INSERT INTO #tech(MASTER_ID, NAME_DATA, VALUE_DATA, STAT)
		    SELECT
			    (
				    SELECT ID
				    FROM #tech
				    WHERE USR_ID = a.ClientBaseID
					    AND NAME_DATA = @tech
			    ), 'Версия файла USR', FormatVersion, CASE FormatVersion WHEN 4 THEN 0 WHEN 5 THEN 0 ELSE 2 END
		    FROM #usr a

	    INSERT INTO #tech(MASTER_ID, NAME_DATA, VALUE_DATA, STAT)
		    SELECT
			    (
				    SELECT ID
				    FROM #tech
				    WHERE USR_ID = a.ClientBaseID
					    AND NAME_DATA = @tech
			    ), 'Версия файла cons.exe', ConsExeVersion, CASE WHEN ConsExeVersion IN (SELECT ConsExeVersionName FROM ClientDB.dbo.ConsExeVersionTable WHERE ConsExeVersionActive = 1) THEN 0 ELSE 2 END
		    FROM #usr a


	    INSERT INTO #tech(MASTER_ID, NAME_DATA, VALUE_DATA, STAT)
		    SELECT
			    (
				    SELECT ID
				    FROM #tech
				    WHERE USR_ID = a.ClientBaseID
					    AND NAME_DATA = @tech
			    ), 'Версия техн.модуля', ResVersion,
			     CASE
				    WHEN ResVersion IN
					    (
						    SELECT ResVersionNumber
						    FROM ClientDB.dbo.ResVersionTable
						    WHERE IsLatest = 1
					    ) THEN 0 
				    ELSE 2
			    END
		    FROM #usr a

	    INSERT INTO #tech(MASTER_ID, NAME_DATA, VALUE_DATA, STAT)
		    SELECT
			    (
				    SELECT ID
				    FROM #tech
				    WHERE USR_ID = a.ClientBaseID
					    AND NAME_DATA = @tech
			    ), 'Процессор', ProcessorName + ' (' + ProcessorFrequency + ' x' + CONVERT(VARCHAR(10), ProcessorCores) + ')', 0
		    FROM #usr a

	    INSERT INTO #tech(MASTER_ID, NAME_DATA, VALUE_DATA, STAT)
		    SELECT
			    (
				    SELECT ID
				    FROM #tech
				    WHERE USR_ID = a.ClientBaseID
					    AND NAME_DATA = @tech
			    ), 'Объем оперативной памяти', RAM, CASE WHEN CONVERT(INT, RAM) < '255' THEN 2 ELSE 0 END
		    FROM #usr a

	    INSERT INTO #tech(MASTER_ID, NAME_DATA, VALUE_DATA, STAT)
		    SELECT
			    (
				    SELECT ID
				    FROM #tech
				    WHERE USR_ID = a.ClientBaseID
					    AND NAME_DATA = @tech
			    ), 'Загрузочный диск', BootDiskName + ' (своб. ' + BootDiskFreeSpace + ')',
			    CASE WHEN CONVERT(BIGINT, BootDiskFreeSpace) < 1000 THEN 2 ELSE 0 END
		    FROM #usr a

	    INSERT INTO #tech(MASTER_ID, NAME_DATA, VALUE_DATA, STAT)
		    SELECT
			    (
				    SELECT ID
				    FROM #tech
				    WHERE USR_ID = a.ClientBaseID
					    AND NAME_DATA = @tech
			    ), 'Свободно на диске с К+', DiskFreeSpace,
			    CASE WHEN CONVERT(BIGINT, DiskFreeSpace) < 1000 THEN 2 ELSE 0 END
		    FROM #usr a



	    INSERT INTO #tech(MASTER_ID, NAME_DATA, VALUE_DATA)
		    SELECT
			    (
				    SELECT ID
				    FROM #tech
				    WHERE USR_ID = a.ClientBaseID
					    AND NAME_DATA = @tech
			    ), 'Операционная система', OSName
		    FROM #usr a


	    INSERT INTO #tech(MASTER_ID, NAME_DATA, VALUE_DATA)
		    SELECT
			    (
				    SELECT ID
				    FROM #tech
				    WHERE USR_ID = a.ClientBaseID
					    AND NAME_DATA = @tech
			    ), 'Версия пакета офисных программ ', Office
		    FROM #usr a
    

	    INSERT INTO #tech(MASTER_ID, NAME_DATA, VALUE_DATA)
		    SELECT
			    (
				    SELECT ID
				    FROM #tech
				    WHERE USR_ID = a.ClientBaseID
					    AND NAME_DATA = @tech
			    ), 'Интернет-браузер по-умолчанию', Browser
		    FROM #usr a

	    INSERT INTO #tech(MASTER_ID, NAME_DATA, VALUE_DATA)
		    SELECT
			    (
				    SELECT ID
				    FROM #tech
				    WHERE USR_ID = a.ClientBaseID
					    AND NAME_DATA = @tech
			    ), 'Почтовый агент', MailAgent
		    FROM #usr a

	    INSERT INTO #tech(MASTER_ID, NAME_DATA, VALUE_DATA)
		    SELECT
			    (
				    SELECT ID
				    FROM #tech
				    WHERE USR_ID = a.ClientBaseID
					    AND NAME_DATA = @tech
			    ), 'Права доступа', Rights
		    FROM #usr a

	    INSERT INTO #tech(MASTER_ID, NAME_DATA, VALUE_DATA)
		    SELECT
			    (
				    SELECT ID
				    FROM #tech
				    WHERE USR_ID = a.ClientBaseID
					    AND NAME_DATA = @cons
			    ), 'Кол-во одновременных доступов', ODUsers
		    FROM #usr a

	    INSERT INTO #tech(MASTER_ID, NAME_DATA, VALUE_DATA)
		    SELECT
			    (
				    SELECT ID
				    FROM #tech
				    WHERE USR_ID = a.ClientBaseID
					    AND NAME_DATA = @cons
			    ), 'Кол-во уникальных доступов', UDUsers
		    FROM #usr a

	    INSERT INTO #tech(MASTER_ID, NAME_DATA, VALUE_DATA)
		    SELECT
			    (
				    SELECT ID
				    FROM #tech
				    WHERE USR_ID = a.ClientBaseID
					    AND NAME_DATA = @cons
			    ), 'Кол-во терминальных доступов', TSUsers
		    FROM #usr a

	    INSERT INTO #tech(MASTER_ID, NAME_DATA, VALUE_DATA)
		    SELECT
			    (
				    SELECT ID
				    FROM #tech
				    WHERE USR_ID = a.ClientBaseID
					    AND NAME_DATA = @cons
			    ), 'Использование в виртуальной среде', VMUsers
		    FROM #usr a
    /*
	    INSERT INTO #tech(MASTER_ID, NAME_DATA, VALUE_DATA)
		    SELECT
			    (
				    SELECT ID
				    FROM #tech
				    WHERE USR_ID = a.ClientBaseID
					    AND NAME_DATA = @cons
			    ), 'Дата файла Info.cfg', (CONVERT(VARCHAR(20), CONVERT(DATETIME, InfoCfgFileDate, 112), 104) + ' ' + InfoCfgFileTime)
		    FROM #usr a
    */
	    INSERT INTO #tech(MASTER_ID, NAME_DATA, VALUE_DATA)
		    SELECT
			    (
				    SELECT ID
				    FROM #tech
				    WHERE USR_ID = a.ClientBaseID
					    AND NAME_DATA = @cons
			    ), 'Дата файла Consult.tor', (CONVERT(VARCHAR(20), CONVERT(DATETIME, ConsultTorFileDate, 112), 104) + ' ' + ConsultTorFileTime)
		    FROM #usr a

	    INSERT INTO #tech(MASTER_ID, NAME_DATA, VALUE_DATA)
		    SELECT
			    (
				    SELECT ID
				    FROM #tech
				    WHERE USR_ID = a.ClientBaseID
					    AND NAME_DATA = @cons
			    ), 'Дата файла USR', (CONVERT(VARCHAR(20), CONVERT(DATETIME, USRFileDate, 112), 104) + ' ' + USRFileTime)
		    FROM #usr a

	    INSERT INTO #tech(MASTER_ID, NAME_DATA, VALUE_DATA, STAT)
		    SELECT
			    (
				    SELECT ID
				    FROM #tech
				    WHERE USR_ID = a.ClientBaseID
					    AND NAME_DATA = @cons
			    ), '№ РИЦ', Ric, CASE Ric WHEN '20' THEN 0 ELSE 4 END
		    FROM #usr a

	    INSERT INTO #tech(MASTER_ID, NAME_DATA, VALUE_DATA, STAT)
		    SELECT
			    (
				    SELECT ID
				    FROM #tech
				    WHERE USR_ID = a.ClientBaseID
					    AND NAME_DATA = @cons
			    ), 'Время пополнения', USRFileUptime,
			    CASE WHEN USRFileUptime > '00.40.00' THEN 4 ELSE 0 END
		    FROM #usr a


	    INSERT INTO #tech(MASTER_ID, USR_ID, NAME_DATA, VALUE_DATA, STAT)
		    SELECT
			    (
				    SELECT ID
				    FROM #tech
				    WHERE USR_ID = a.ClientBaseID
					    AND NAME_DATA = @complect
			    ), ClientBaseID, @system, '', 3
		    FROM #usr a
    
	    INSERT INTO #tech(MASTER_ID, USR_ID, PACKAGE_ID, NAME_DATA, VALUE_DATA)
		    SELECT
			    (
				    SELECT ID
				    FROM #tech
				    WHERE USR_ID = a.ClientBaseID
					    AND NAME_DATA = @system
			    ), a.ClientBaseID,
			    CASE
				    WHEN  SystemID IS NULL THEN 0
				    ELSE PackageID
			    END AS PackageID,
			    ISNULL(c.SystemShortName, PackageName) + ' ' +
			    CASE CompNumber
				    WHEN 1 THEN CONVERT(VARCHAR(20), DistrNumber)
				    ELSE CONVERT(VARCHAR(20), DistrNumber) + '/' + CONVERT(VARCHAR(20), CompNumber)
			    END,
			    CASE ISNULL(TT_REG, -1)
				    WHEN -1 THEN 'Неизвестно'
				    WHEN 0 THEN SN_NAME +
					    CASE SNC_NET_COUNT
						    WHEN 0 THEN ''
						    WHEN 1 THEN ''
						    ELSE ' ' + CONVERT(VARCHAR(50), SNC_NET_COUNT)
					    END
				    ELSE TT_NAME END + ' / ' + SST_CAPTION + ' / РИЦ : ' + CONVERT(VARCHAR(20), a.Ric)
		    FROM
			    ClientDB.dbo.USRPackageTable a INNER JOIN
			    #usr b ON a.ClientBaseID = b.ClientBaseID LEFT OUTER JOIN
			    ClientDB.dbo.SystemTable c ON c.SystemBaseName + '_' + CONVERT(VARCHAR(5), SystemNumber) = a.PackageName LEFT OUTER JOIN
			    [PC275-SQL\DELTA].DBF.dbo.SystemTypeTable ON SST_NAME = UserType LEFT OUTER JOIN
			    [PC275-SQL\DELTA].DBF.dbo.SystemNetCountTable ON SNC_NET_COUNT = NetCount LEFT OUTER JOIN
			    [PC275-SQL\DELTA].DBF.dbo.SystemNetTable ON SN_ID = SNC_ID_SN LEFT OUTER JOIN
			    [PC275-SQL\DELTA].DBF.dbo.TechnolTypeTable ON TT_USR = TechnolType
    
		    ORDER BY SystemOrder, SystemShortName

	    INSERT INTO #tech(MASTER_ID, USR_ID, PACKAGE_ID, BASE_ID, NAME_DATA, VALUE_DATA, STAT)
		    SELECT
			    (
				    SELECT ID
				    FROM #tech
				    WHERE PACKAGE_ID = PackageID
			    ), ClientBaseID, PackageID, BaseID, DirectoryName, ValueName,
			    CASE
				    WHEN Compliance = '#HOST' THEN 2
				    ELSE 0
			    END
		    FROM
			    (
				    SELECT
					    a.ClientBaseID,
					    ISNULL((
					    SELECT TOP 1 PackageID
					    FROM
						    ClientDB.dbo.USRPackageTable e INNER JOIN
						    ClientDB.dbo.SystemTable f ON f.SystemBaseName = LEFT(PackageName, CHARINDEX('_', PackageName) - 1) INNER JOIN
						    ClientDB.dbo.SystemBankTable g ON g.SystemID = f.SystemID
									    AND g.InfoBankID = c.InfoBankID
					    WHERE e.ClientBaseID = a.ClientBaseID
						    AND e.DistrNumber = a.DistrNumber
						    AND e.CompNumber = a.CompNumber
					    ORDER BY 	PackageID
					    ), 0) AS PackageID,
					    BaseID, Compliance,
					    ISNULL(InfoBankShortName, DirectoryName) AS DirectoryName,
					    (
						    SELECT TOP 1
							    DATENAME(dw, CONVERT(DATETIME, UpdateDate, 112)) + REPLICATE(' ', 12 - LEN(DATENAME(dw, CONVERT(DATETIME, USRFileDate, 112)))) +
							    CONVERT(VARCHAR(20), CONVERT(DATETIME, UpdateDate, 112), 104) + '     ' + UpdateTime + '  (' + CONVERT(VARCHAR(20), UpdateDocs) + ')'
						    FROM ClientDB.dbo.USRIBUpdateTable h
						    WHERE h.BaseID = a.BaseID
							    AND CONVERT(DATETIME, UpdateDate, 112) <= GETDATE()
						    ORDER BY UpdateDate DESC, UpdateTime DESC
					    ) + '     ' +	ISNULL(ComplianceTypeShortName, Compliance) AS ValueName, InfoBankOrder
				    FROM
					    ClientDB.dbo.USRIBTable a INNER JOIN
					    #usr b ON a.ClientBaseID = b.ClientBaseID LEFT OUTER JOIN
					    ClientDB.dbo.InfoBankTable c ON InfoBankName = DirectoryName LEFT OUTER JOIN
					    ClientDB.dbo.ComplianceTypeTable d ON Compliance = ComplianceTypeName
			    ) AS o_O
		    WHERE EXISTS (
				    SELECT *
				    FROM #tech
				    WHERE PACKAGE_ID = PackageID
			    )
		    ORDER BY InfoBankOrder


	    INSERT INTO #tech(MASTER_ID, NAME_DATA, VALUE_DATA, STAT)
		    SELECT
			    (
				    SELECT TOP 1 ID
				    FROM #tech
				    WHERE BASE_ID = a.BaseID
				    ORDER BY ID
			    ),
			    CONVERT(VARCHAR(20), CONVERT(DATETIME, UpdateDate, 112), 104) + '   ' + UpdateTime,
			    DATENAME(dw, CONVERT(DATETIME, UpdateDate, 112)) + REPLICATE(' ', 12 - LEN(DATENAME(dw, CONVERT(DATETIME, USRFileDate, 112)))) + ' ' + CONVERT(VARCHAR(20), CONVERT(DATETIME, UpdateSysDate, 112), 104) + '   (' + CONVERT(VARCHAR(20), UpdateDocs) + ')' + REPLICATE(' ', 12 - LEN(CONVERT(VARCHAR(20), UpdateDocs))) + ' ' + ISNULL(USRFileKindShortName, USRFileKind),
			    CASE UpdateKind
				    WHEN 'R' THEN 4
				    ELSE 0
			    END
		    FROM
			    ClientDB.dbo.USRIBTable a INNER JOIN
			    #usr b ON a.ClientBaseID = b.ClientBaseID INNER JOIN
			    ClientDB.dbo.USRIBUpdateTable c ON c.BaseID = a.BaseID LEFT OUTER JOIN
			    ClientDB.dbo.USRFileKindTable d ON UpdateKind = USRFileKindName
		    WHERE EXISTS
			    (
				    SELECT *
				    FROM #tech
				    WHERE BASE_ID = a.BaseID
			    )
		    ORDER BY UpdateDate DESC, UpdateTime DESC

	    SELECT *
	    FROM #tech
	    ORDER BY ID

	    IF OBJECT_ID('tempdb..#tech')	 IS NOT NULL
		    DROP TABLE #tech

	    IF OBJECT_ID('tempdb..#usr') IS NOT NULL
		    DROP TABLE #usr

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [Client].[CLIENT_TECH_SELECT] TO rl_tech_info;
GO