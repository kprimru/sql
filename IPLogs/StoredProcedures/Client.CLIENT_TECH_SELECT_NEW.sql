﻿USE [IPLogs]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [Client].[CLIENT_TECH_SELECT_NEW]
	@CLIENT	INT,
	@CLIENT_TYPE	NVARCHAR(20) = NULL
WITH EXECUTE AS OWNER
AS
BEGIN
	SET NOCOUNT ON;

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
			UF_ID UNIQUEIDENTIFIER,
			UD_COMPLECT VARCHAR(50),
			UF_FORMAT INT,
			UF_RIC INT,
			UF_ID_RES INT,
			UF_ID_CONS INT,
			UF_PROC_NAME VARCHAR(100),
			UF_PROC_FREQ VARCHAR(50),
			UF_PROC_CORE SMALLINT,
			UF_RAM BIGINT,
			OS_NAME VARCHAR(150),
			OS_MIN VARCHAR(20),
			OS_MAJ VARCHAR(20),
			OS_BUILD VARCHAR(20),
			OS_PLATFORM VARCHAR(20),
			OS_EDITION VARCHAR(50),
			OS_CAPACITY VARCHAR(20),
			OS_LANG VARCHAR(50),
			OS_COMPATIBILITY VARCHAR(50),
			UF_BOOT_NAME VARCHAR(10),
			UF_BOOT_FREE BIGINT,
			UF_CONS_FREE BIGINT,
			UF_OFFICE VARCHAR(100),
			UF_BROWSER VARCHAR(100),
			UF_MAIL VARCHAR(100),
			UF_RIGHT VARCHAR(50),
			UF_OD SMALLINT,
			UF_UD SMALLINT,
			UF_TS SMALLINT,
			UF_VM SMALLINT,
			UF_DATE	DATETIME,
			UF_ID_KIND INT,
			UF_UPTIME VARCHAR(20),
			UF_INFO_COD DATETIME,
			UF_INFO_CFG DATETIME,
			UF_CONSULT_TOR DATETIME,
		CONSTRAINT [PK_TMP_USR] PRIMARY KEY NONCLUSTERED
			(
				[UF_ID] ASC
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
				UF_ID, UD_COMPLECT, UF_FORMAT, UF_RIC, UF_ID_RES, UF_ID_CONS,
				UF_PROC_NAME, UF_PROC_FREQ, UF_PROC_CORE, UF_RAM,
				OS_NAME, OS_MIN, OS_MAJ, OS_BUILD, OS_PLATFORM,
				OS_EDITION, OS_CAPACITY, OS_LANG, OS_COMPATIBILITY,
				UF_BOOT_NAME, UF_BOOT_FREE, UF_CONS_FREE,
				UF_OFFICE, UF_BROWSER, UF_MAIL, UF_RIGHT,
				UF_OD, UF_UD, UF_TS, UF_VM,
				UF_DATE, UF_ID_KIND, UF_UPTIME, UF_INFO_COD,
				UF_INFO_CFG, UF_CONSULT_TOR
			)
			SELECT
				a.UF_ID, UD_COMPLECT, UF_FORMAT, UF_RIC, a.UF_ID_RES, a.UF_ID_CONS,
				PRC_NAME, PRC_FREQ_S, PRC_CORE, UF_RAM,
				OS_NAME, OS_MIN, OS_MAJ, OS_BUILD, OS_PLATFORM,
				OS_EDITION, OS_CAPACITY, OS_LANG, OS_COMPATIBILITY,
				UF_BOOT_NAME, UF_BOOT_FREE, UF_CONS_FREE,
				UF_OFFICE, UF_BROWSER, UF_MAIL, UF_RIGHT,
				UF_OD, UF_UD, UF_TS, UF_VM,
				a.UF_DATE, UF_ID_KIND, a.UF_UPTIME, UF_INFO_COD,
				UF_INFO_CFG, UF_CONSULT_TOR
			FROM
				[PC275-SQL\ALPHA].ClientDB.USR.USRActiveView a
				INNER JOIN [PC275-SQL\ALPHA].ClientDB.USR.USRFile b ON a.UF_ID = b.UF_ID
				INNER JOIN [PC275-SQL\ALPHA].ClientDB.USR.OS ON OS_ID = UF_ID_OS
				LEFT OUTER JOIN [PC275-SQL\ALPHA].ClientDB.USR.Processor ON PRC_ID = UF_ID_PROC
			WHERE UD_ID_CLIENT = @CLIENT
			ORDER BY UF_DATE DESC
	ELSE IF @CLIENT_TYPE = 'DBF'
		INSERT INTO #usr
			(
				UF_ID, UD_COMPLECT, UF_FORMAT, UF_RIC, UF_ID_RES, UF_ID_CONS,
				UF_PROC_NAME, UF_PROC_FREQ, UF_PROC_CORE, UF_RAM,
				OS_NAME, OS_MIN, OS_MAJ, OS_BUILD, OS_PLATFORM,
				OS_EDITION, OS_CAPACITY, OS_LANG, OS_COMPATIBILITY,
				UF_BOOT_NAME, UF_BOOT_FREE, UF_CONS_FREE,
				UF_OFFICE, UF_BROWSER, UF_MAIL, UF_RIGHT,
				UF_OD, UF_UD, UF_TS, UF_VM,
				UF_DATE, UF_ID_KIND, UF_UPTIME, UF_INFO_COD,
				UF_INFO_CFG, UF_CONSULT_TOR
			)
			SELECT
				a.UF_ID, UD_COMPLECT, UF_FORMAT, UF_RIC, a.UF_ID_RES, a.UF_ID_CONS,
				PRC_NAME, PRC_FREQ_S, PRC_CORE, UF_RAM,
				OS_NAME, OS_MIN, OS_MAJ, OS_BUILD, OS_PLATFORM,
				OS_EDITION, OS_CAPACITY, OS_LANG, OS_COMPATIBILITY,
				UF_BOOT_NAME, UF_BOOT_FREE, UF_CONS_FREE,
				UF_OFFICE, UF_BROWSER, UF_MAIL, UF_RIGHT,
				UF_OD, UF_UD, UF_TS, UF_VM,
				a.UF_DATE, UF_ID_KIND, a.UF_UPTIME, UF_INFO_COD,
				UF_INFO_CFG, UF_CONSULT_TOR
			FROM
				[PC275-SQL\ALPHA].ClientDB.USR.USRActiveView a
				INNER JOIN [PC275-SQL\ALPHA].ClientDB.USR.USRFile b ON a.UF_ID = b.UF_ID
				INNER JOIN [PC275-SQL\ALPHA].ClientDB.USR.OS ON OS_ID = UF_ID_OS
				INNER JOIN [PC275-SQL\ALPHA].ClientDB.USR.Processor ON PRC_ID = UF_ID_PROC
			WHERE EXISTS
				(
					SELECT *
					FROM
						[PC275-SQL\ALPHA].ClientDB.USR.USRPackage c INNER JOIN
						[PC275-SQL\ALPHA].ClientDB.dbo.SystemTable f ON f.SystemID = c.UP_ID_SYSTEM INNER JOIN
						[PC275-SQL\DELTA].DBF.dbo.DistrView d ON
											c.UP_DISTR = d.DIS_NUM
										AND c.UP_COMP = d.DIS_COMP_NUM
										AND SystemBaseName = SYS_REG_NAME INNER JOIN
						[PC275-SQL\DELTA].DBF.dbo.TODistrTable e ON TD_ID_DISTR = DIS_ID
					WHERE c.UP_ID_USR = b.UF_ID
						AND TD_ID_TO = @CLIENT
				)
			ORDER BY UF_DATE DESC
	ELSE IF @CLIENT_TYPE = 'REG' AND @CLIENT <> -1
		INSERT INTO #usr
			(
				UF_ID, UD_COMPLECT, UF_FORMAT, UF_RIC, UF_ID_RES, UF_ID_CONS,
				UF_PROC_NAME, UF_PROC_FREQ, UF_PROC_CORE, UF_RAM,
				OS_NAME, OS_MIN, OS_MAJ, OS_BUILD, OS_PLATFORM,
				OS_EDITION, OS_CAPACITY, OS_LANG, OS_COMPATIBILITY,
				UF_BOOT_NAME, UF_BOOT_FREE, UF_CONS_FREE,
				UF_OFFICE, UF_BROWSER, UF_MAIL, UF_RIGHT,
				UF_OD, UF_UD, UF_TS, UF_VM,
				UF_DATE, UF_ID_KIND, UF_UPTIME, UF_INFO_COD,
				UF_INFO_CFG, UF_CONSULT_TOR
			)
			SELECT
				a.UF_ID, UD_COMPLECT, UF_FORMAT, UF_RIC, a.UF_ID_RES, a.UF_ID_CONS,
				PRC_NAME, PRC_FREQ_S, PRC_CORE, UF_RAM,
				OS_NAME, OS_MIN, OS_MAJ, OS_BUILD, OS_PLATFORM,
				OS_EDITION, OS_CAPACITY, OS_LANG, OS_COMPATIBILITY,
				UF_BOOT_NAME, UF_BOOT_FREE, UF_CONS_FREE,
				UF_OFFICE, UF_BROWSER, UF_MAIL, UF_RIGHT,
				UF_OD, UF_UD, UF_TS, UF_VM,
				a.UF_DATE, UF_ID_KIND, a.UF_UPTIME, UF_INFO_COD,
				UF_INFO_CFG, UF_CONSULT_TOR
			FROM
				[PC275-SQL\ALPHA].ClientDB.USR.USRActiveView a
				INNER JOIN [PC275-SQL\ALPHA].ClientDB.USR.USRFile b ON a.UF_ID = b.UF_ID
				INNER JOIN [PC275-SQL\ALPHA].ClientDB.USR.OS ON OS_ID = UF_ID_OS
				INNER JOIN [PC275-SQL\ALPHA].ClientDB.USR.Processor ON PRC_ID = UF_ID_PROC
			WHERE EXISTS
				(
					SELECT *
					FROM
						[PC275-SQL\ALPHA].ClientDB.USR.USRPackage c INNER JOIN
						[PC275-SQL\ALPHA].ClientDB.dbo.SystemTable f ON f.SystemID = c.UP_ID_SYSTEM INNER JOIN
						[PC275-SQL\ALPHA].ClientDB.dbo.RegNodeTable p ON p.SystemName = f.SystemBaseName
											AND c.UP_DISTR = p.DistrNumber
											AND c.UP_COMP = p.CompNumber
					WHERE c.UP_ID_USR = b.UF_ID
						AND ID = @CLIENT
				)
			ORDER BY UF_DATE DESC
	ELSE IF @CLIENT_TYPE = 'REG' AND @CLIENT = -1
		INSERT INTO #usr
			(
				UF_ID, UD_COMPLECT, UF_FORMAT, UF_RIC, UF_ID_RES, UF_ID_CONS,
				UF_PROC_NAME, UF_PROC_FREQ, UF_PROC_CORE, UF_RAM,
				OS_NAME, OS_MIN, OS_MAJ, OS_BUILD, OS_PLATFORM,
				OS_EDITION, OS_CAPACITY, OS_LANG, OS_COMPATIBILITY,
				UF_BOOT_NAME, UF_BOOT_FREE, UF_CONS_FREE,
				UF_OFFICE, UF_BROWSER, UF_MAIL, UF_RIGHT,
				UF_OD, UF_UD, UF_TS, UF_VM,
				UF_DATE, UF_ID_KIND, UF_UPTIME, UF_INFO_COD,
				UF_INFO_CFG, UF_CONSULT_TOR
			)
			SELECT
				a.UF_ID, UD_COMPLECT, UF_FORMAT, UF_RIC, a.UF_ID_RES, a.UF_ID_CONS,
				PRC_NAME, PRC_FREQ_S, PRC_CORE, UF_RAM,
				OS_NAME, OS_MIN, OS_MAJ, OS_BUILD, OS_PLATFORM,
				OS_EDITION, OS_CAPACITY, OS_LANG, OS_COMPATIBILITY,
				UF_BOOT_NAME, UF_BOOT_FREE, UF_CONS_FREE,
				UF_OFFICE, UF_BROWSER, UF_MAIL, UF_RIGHT,
				UF_OD, UF_UD, UF_TS, UF_VM,
				a.UF_DATE, UF_ID_KIND, a.UF_UPTIME, UF_INFO_COD,
				UF_INFO_CFG, UF_CONSULT_TOR
			FROM
				[PC275-SQL\ALPHA].ClientDB.USR.USRActiveView a
				INNER JOIN [PC275-SQL\ALPHA].ClientDB.USR.USRFile b ON a.UF_ID = b.UF_ID
				INNER JOIN [PC275-SQL\ALPHA].ClientDB.USR.OS ON OS_ID = UF_ID_OS
				INNER JOIN [PC275-SQL\ALPHA].ClientDB.USR.Processor ON PRC_ID = UF_ID_PROC
			WHERE EXISTS
				(
					SELECT *
					FROM [PC275-SQL\ALPHA].ClientDB.USR.USRPackage c
					WHERE c.UP_ID_USR = b.UF_ID
						AND c.UP_DISTR = 490
				)
			ORDER BY UF_DATE DESC


	CREATE TABLE #tech
		(
			ID	INT IDENTITY(1, 1) PRIMARY KEY,
			MASTER_ID INT,
			USR_ID	UNIQUEIDENTIFIER,
			PACKAGE_ID	UNIQUEIDENTIFIER,
			BASE_ID	UNIQUEIDENTIFIER,
			NAME_DATA	VARCHAR(500),
			VALUE_DATA	VARCHAR(1000),
			STAT SMALLINT DEFAULT 0
		)

	INSERT INTO #tech(MASTER_ID, USR_ID, NAME_DATA, VALUE_DATA, STAT)
		SELECT NULL,  UF_ID, @complect, UD_COMPLECT,
			CASE
				WHEN EXISTS
					(
						SELECT *
						FROM
							[PC275-SQL\ALPHA].ClientDB.USR.USRIB INNER JOIN
							[PC275-SQL\ALPHA].ClientDB.dbo.ComplianceTypeTable ON ComplianceTypeID = UI_ID_COMP
						WHERE UF_ID = UI_ID_USR
							AND ComplianceTypeName = '#HOST'
							AND UI_DISTR <> 1
					) THEN 2
				ELSE 1
			END
		FROM #usr a

	INSERT INTO #tech(MASTER_ID, USR_ID, NAME_DATA, VALUE_DATA, STAT)
		SELECT
			(
				SELECT ID
				FROM #tech
				WHERE USR_ID = UF_ID
					AND NAME_DATA = @complect
			), UF_ID, @tech, '', 3
		FROM #usr a

	INSERT INTO #tech(MASTER_ID, USR_ID, NAME_DATA, VALUE_DATA, STAT)
		SELECT
			(
				SELECT ID
				FROM #tech
				WHERE USR_ID = UF_ID
					AND NAME_DATA = @complect
			), UF_ID, @cons, '', 3
		FROM #usr a



	INSERT INTO #tech(MASTER_ID, NAME_DATA, VALUE_DATA, STAT)
		SELECT
			(
				SELECT ID
				FROM #tech
				WHERE USR_ID = UF_ID
					AND NAME_DATA = @tech
			), 'Версия файла USR', UF_FORMAT, CASE UF_FORMAT WHEN 4 THEN 0 WHEN 5 THEN 0 ELSE 0 END
		FROM #usr a

	INSERT INTO #tech(MASTER_ID, NAME_DATA, VALUE_DATA, STAT)
		SELECT
			(
				SELECT ID
				FROM #tech
				WHERE USR_ID = UF_ID
					AND NAME_DATA = @tech
			), 'Версия файла cons.exe', ConsExeVersionName, CASE ConsExeVersionActive WHEN 1 THEN 0 ELSE 2 END
		FROM
			#usr a	LEFT OUTER JOIN
			[PC275-SQL\ALPHA].ClientDB.dbo.ConsExeVersionTable ON ConsExeVersionID = UF_ID_CONS


	INSERT INTO #tech(MASTER_ID, NAME_DATA, VALUE_DATA, STAT)
		SELECT
			(
				SELECT ID
				FROM #tech
				WHERE USR_ID = UF_ID
					AND NAME_DATA = @tech
			), 'Версия техн.модуля', ResVersionNumber,
			 CASE IsLatest
				WHEN 1 THEN 0 
				ELSE 2
			END
		FROM
			#usr a	INNER JOIN
			[PC275-SQL\ALPHA].ClientDB.dbo.ResVersionTable ON ResVersionID = UF_ID_RES

	INSERT INTO #tech(MASTER_ID, NAME_DATA, VALUE_DATA, STAT)
		SELECT
			(
				SELECT ID
				FROM #tech
				WHERE USR_ID = UF_ID
					AND NAME_DATA = @tech
			), 'Процессор', UF_PROC_NAME + ' (' + UF_PROC_FREQ + ' x' + CONVERT(VARCHAR(10), UF_PROC_CORE) + ')', 0
		FROM #usr a

	INSERT INTO #tech(MASTER_ID, NAME_DATA, VALUE_DATA, STAT)
		SELECT
			(
				SELECT ID
				FROM #tech
				WHERE USR_ID = UF_ID
					AND NAME_DATA = @tech
			), 'Объем оперативной памяти', UF_RAM, CASE WHEN UF_RAM < 255 THEN 2 ELSE 0 END
		FROM #usr a

	INSERT INTO #tech(MASTER_ID, NAME_DATA, VALUE_DATA, STAT)
		SELECT
			(
				SELECT ID
				FROM #tech
				WHERE USR_ID = UF_ID
					AND NAME_DATA = @tech
			), 'Загрузочный диск', UF_BOOT_NAME + ' (своб. ' + CONVERT(VARCHAR(20), UF_BOOT_FREE) + ')',
			CASE WHEN UF_BOOT_FREE < 1000 THEN 2 ELSE 0 END
		FROM #usr a

	INSERT INTO #tech(MASTER_ID, NAME_DATA, VALUE_DATA, STAT)
		SELECT
			(
				SELECT ID
				FROM #tech
				WHERE USR_ID = UF_ID
					AND NAME_DATA = @tech
			), 'Свободно на диске с К+', UF_CONS_FREE,
			CASE WHEN UF_CONS_FREE < 1000 THEN 2 ELSE 0 END
		FROM #usr a



	INSERT INTO #tech(MASTER_ID, NAME_DATA, VALUE_DATA)
		SELECT
			(
				SELECT ID
				FROM #tech
				WHERE USR_ID = UF_ID
					AND NAME_DATA = @tech
			), 'Операционная система', OS_NAME
		FROM #usr a


	INSERT INTO #tech(MASTER_ID, NAME_DATA, VALUE_DATA)
		SELECT
			(
				SELECT ID
				FROM #tech
				WHERE USR_ID = UF_ID
					AND NAME_DATA = @tech
			), 'Версия пакета офисных программ ', UF_OFFICE
		FROM #usr a


	INSERT INTO #tech(MASTER_ID, NAME_DATA, VALUE_DATA)
		SELECT
			(
				SELECT ID
				FROM #tech
				WHERE USR_ID = UF_ID
					AND NAME_DATA = @tech
			), 'Интернет-браузер по-умолчанию', UF_BROWSER
		FROM #usr a

	INSERT INTO #tech(MASTER_ID, NAME_DATA, VALUE_DATA)
		SELECT
			(
				SELECT ID
				FROM #tech
				WHERE USR_ID = UF_ID
					AND NAME_DATA = @tech
			), 'Почтовый агент', UF_MAIL
		FROM #usr a

	INSERT INTO #tech(MASTER_ID, NAME_DATA, VALUE_DATA)
		SELECT
			(
				SELECT ID
				FROM #tech
				WHERE USR_ID = UF_ID
					AND NAME_DATA = @tech
			), 'Права доступа', UF_RIGHT
		FROM #usr a

	INSERT INTO #tech(MASTER_ID, NAME_DATA, VALUE_DATA)
		SELECT
			(
				SELECT ID
				FROM #tech
				WHERE USR_ID = UF_ID
					AND NAME_DATA = @cons
			), 'Кол-во одновременных доступов', UF_OD
		FROM #usr a

	INSERT INTO #tech(MASTER_ID, NAME_DATA, VALUE_DATA)
		SELECT
			(
				SELECT ID
				FROM #tech
				WHERE USR_ID = UF_ID
					AND NAME_DATA = @cons
			), 'Кол-во уникальных доступов', UF_UD
		FROM #usr a

	INSERT INTO #tech(MASTER_ID, NAME_DATA, VALUE_DATA)
		SELECT
			(
				SELECT ID
				FROM #tech
				WHERE USR_ID = UF_ID
					AND NAME_DATA = @cons
			), 'Кол-во терминальных доступов', UF_TS
		FROM #usr a

	INSERT INTO #tech(MASTER_ID, NAME_DATA, VALUE_DATA)
		SELECT
			(
				SELECT ID
				FROM #tech
				WHERE USR_ID = UF_ID
					AND NAME_DATA = @cons
			), 'Использование в виртуальной среде', UF_VM
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
				WHERE USR_ID = UF_ID
					AND NAME_DATA = @cons
			), 'Дата файла Consult.tor', CONVERT(VARCHAR(20), UF_CONSULT_TOR, 104) + ' ' + CONVERT(VARCHAR(20), UF_CONSULT_TOR, 108)
		FROM #usr a

	INSERT INTO #tech(MASTER_ID, NAME_DATA, VALUE_DATA)
		SELECT
			(
				SELECT ID
				FROM #tech
				WHERE USR_ID = UF_ID
					AND NAME_DATA = @cons
			), 'Дата файла USR',  CONVERT(VARCHAR(20), UF_DATE, 104) + ' ' + CONVERT(VARCHAR(20), UF_DATE, 108)
		FROM #usr a

	INSERT INTO #tech(MASTER_ID, NAME_DATA, VALUE_DATA, STAT)
		SELECT
			(
				SELECT ID
				FROM #tech
				WHERE USR_ID = UF_ID
					AND NAME_DATA = @cons
			), '№ РИЦ', UF_RIC, CASE UF_RIC WHEN '20' THEN 0 ELSE 4 END
		FROM #usr a

	INSERT INTO #tech(MASTER_ID, NAME_DATA, VALUE_DATA, STAT)
		SELECT
			(
				SELECT ID
				FROM #tech
				WHERE USR_ID = UF_ID
					AND NAME_DATA = @cons
			), 'Время пополнения', UF_UPTIME,
			CASE WHEN UF_UPTIME > '00.40.00' THEN 4 ELSE 0 END
		FROM #usr a


	INSERT INTO #tech(MASTER_ID, USR_ID, NAME_DATA, VALUE_DATA, STAT)
		SELECT
			(
				SELECT ID
				FROM #tech
				WHERE USR_ID = UF_ID
					AND NAME_DATA = @complect
			), UF_ID, @system, '', 3
		FROM #usr a

	INSERT INTO #tech(MASTER_ID, USR_ID, PACKAGE_ID, NAME_DATA, VALUE_DATA)
		SELECT
			(
				SELECT ID
				FROM #tech
				WHERE USR_ID = UF_ID
					AND NAME_DATA = @system
			), UF_ID,
			UP_ID AS PackageID,
			c.SystemShortName + ' ' +
			CASE UP_COMP
				WHEN 1 THEN CONVERT(VARCHAR(20), UP_DISTR)
				ELSE CONVERT(VARCHAR(20), UP_DISTR) + '/' + CONVERT(VARCHAR(20), UP_COMP)
			END,
			CASE ISNULL(TT_REG, -1)
				WHEN -1 THEN 'Неизвестно'
				WHEN 0 THEN SN_NAME +
					CASE SNC_NET_COUNT
						WHEN 0 THEN ''
						WHEN 1 THEN ''
						ELSE ' ' + CONVERT(VARCHAR(50), SNC_NET_COUNT)
					END
				ELSE TT_NAME END + ' / ' + SST_CAPTION + ' / РИЦ : ' + CONVERT(VARCHAR(20), UP_RIC)
		FROM
			[PC275-SQL\ALPHA].ClientDB.USR.USRPackage a INNER JOIN
			#usr b ON UF_ID = UP_ID_USR LEFT OUTER JOIN
			[PC275-SQL\ALPHA].ClientDB.dbo.SystemTable c ON c.SystemID = UP_ID_SYSTEM LEFT OUTER JOIN
			[PC275-SQL\DELTA].DBF.dbo.SystemTypeTable ON SST_NAME = UP_TYPE LEFT OUTER JOIN
			[PC275-SQL\DELTA].DBF.dbo.SystemNetCountTable ON SNC_NET_COUNT = UP_NET AND SNC_TECH = UP_TECH LEFT OUTER JOIN
			[PC275-SQL\DELTA].DBF.dbo.SystemNetTable ON SN_ID = SNC_ID_SN LEFT OUTER JOIN
			[PC275-SQL\DELTA].DBF.dbo.TechnolTypeTable ON TT_USR = UP_TECH

		ORDER BY SystemOrder, SystemShortName

	INSERT INTO #tech(MASTER_ID, USR_ID, PACKAGE_ID, BASE_ID, NAME_DATA, VALUE_DATA, STAT)
		SELECT
			(
				SELECT TOP 1 ID
				FROM #tech
				WHERE PACKAGE_ID = PackageID
			), UF_ID, PackageID, UI_ID, DirectoryName, ValueName,
			CASE
				WHEN Compliance = '#HOST' THEN 2
				ELSE 0
			END
		FROM
			(
				SELECT
					UF_ID,
					(
					SELECT TOP 1 UP_ID
					FROM
						[PC275-SQL\ALPHA].ClientDB.USR.USRPackage e INNER JOIN
						[PC275-SQL\ALPHA].ClientDB.dbo.SystemTable f ON f.SystemID = UP_ID_SYSTEM INNER JOIN
						[PC275-SQL\ALPHA].ClientDB.dbo.SystemBankTable g ON g.SystemID = f.SystemID
									AND g.InfoBankID = c.InfoBankID
					WHERE e.UP_ID_USR = a.UI_ID_USR
						AND e.UP_DISTR = a.UI_DISTR
						AND e.UP_COMP = a.UI_COMP
					ORDER BY UP_ID
					) AS PackageID,
					UI_ID, ComplianceTypeName AS Compliance,
					InfoBankShortName AS DirectoryName,
					(
						SELECT TOP 1
							DATENAME(dw, CONVERT(DATETIME, UIU_DATE, 112)) + REPLICATE(' ', 12 - LEN(DATENAME(dw, CONVERT(DATETIME, UIU_DATE, 112)))) +
							CONVERT(VARCHAR(20), UIU_DATE, 104) + '     ' + CONVERT(VARCHAR(20), UIU_DATE, 108) + '  (' + CONVERT(VARCHAR(20), UIU_DOCS) + ')'
						FROM [PC275-SQL\ALPHA].ClientDB.USR.USRUpdates h
						WHERE UIU_ID_IB = UI_ID
							AND UIU_DATE_S <= GETDATE()
						ORDER BY UIU_DATE DESC
					) + '     ' + ComplianceTypeShortName AS ValueName, InfoBankOrder
				FROM
					[PC275-SQL\ALPHA].ClientDB.USR.USRIB a INNER JOIN
					#usr b ON b.UF_ID = a.UI_ID_USR LEFT OUTER JOIN
					[PC275-SQL\ALPHA].ClientDB.dbo.InfoBankTable c ON InfoBankID = UI_ID_BASE LEFT OUTER JOIN
					[PC275-SQL\ALPHA].ClientDB.dbo.ComplianceTypeTable d ON UI_ID_COMP = ComplianceTypeID
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
				WHERE BASE_ID = UI_ID
				ORDER BY ID
			),
			CONVERT(VARCHAR(20), UIU_DATE, 104) + '   ' + CONVERT(VARCHAR(20), UIU_DATE, 108),
			DATENAME(dw, UIU_DATE) + REPLICATE(' ', 12 - LEN(DATENAME(dw, UIU_DATE))) + ' ' + CONVERT(VARCHAR(20), CONVERT(DATETIME, UIU_SYS, 112), 104) + '   (' + CONVERT(VARCHAR(20), UIU_DOCS) + ')' + REPLICATE(' ', 12 - LEN(CONVERT(VARCHAR(20), UIU_DOCS))) + ' ' + USRFileKindShortName,
			CASE USRFileKindName
				WHEN 'R' THEN 4
				ELSE 0
			END
		FROM
			[PC275-SQL\ALPHA].ClientDB.USR.USRIB a INNER JOIN
			#usr b ON a.UI_ID_USR = b.UF_ID INNER JOIN
			[PC275-SQL\ALPHA].ClientDB.USR.USRUpdates c ON UIU_ID_IB = UI_ID LEFT OUTER JOIN
			[PC275-SQL\ALPHA].ClientDB.dbo.USRFileKindTable d ON UIU_ID_KIND = USRFileKindID
		WHERE EXISTS
			(
				SELECT *
				FROM #tech
				WHERE BASE_ID = UI_ID
			)
		ORDER BY UIU_DATE DESC

	SELECT *
	FROM #tech
	ORDER BY ID

	IF OBJECT_ID('tempdb..#tech')	 IS NOT NULL
		DROP TABLE #tech

	IF OBJECT_ID('tempdb..#usr') IS NOT NULL
		DROP TABLE #usr
END
GO
GRANT EXECUTE ON [Client].[CLIENT_TECH_SELECT_NEW] TO rl_tech_info;
GO
