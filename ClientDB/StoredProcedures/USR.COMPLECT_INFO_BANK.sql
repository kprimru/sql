USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [USR].[COMPLECT_INFO_BANK]
	@UF_ID	INT
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

		SET LANGUAGE RUSSIAN

		DECLARE @DAILY	TINYINT
		DECLARE @DAY	TINYINT
		DECLARE @UD_ID	INT
		DECLARE @MIN	SMALLDATETIME
		DECLARE @MAX	SMALLDATETIME	
		DECLARE @CLIENT	INT
		DECLARE @MaxRn	Int

		DECLARE @SystemXML	Xml;
		
		DECLARE @IBs	Table
		(
			InfoBank_Id			SmallInt Primary Key Clustered,
			InfoBankShortName	VarChar(100)
		);

		SELECT @UD_ID = UF_ID_COMPLECT, @MIN = UF_MIN_DATE, @MAX = UF_MAX_DATE, @CLIENT = UD_ID_CLIENT
		FROM USR.USRFile
		INNER JOIN USR.USRData ON UF_ID_COMPLECT = UD_ID
		WHERE UF_ID = @UF_ID

		IF OBJECT_ID('tempdb..#tech_info') IS NOT NULL
			DROP TABLE #tech_info

		CREATE TABLE #tech_info
		(
			UIU_ID					INT PRIMARY KEY,
			UIU_ID_IB				INT,
			UIU_INDX				TINYINT,
			UIU_DATE				SMALLDATETIME,
			UIU_DATE_S				SMALLDATETIME,
			UIU_DOCS				INT,			
			UI_ID_BASE				INT,
			UI_DISTR				INT,
			UI_COMP					TINYINT,
			UI_ID_COMP				INT,
			USRFileKindShortName	VARCHAR(20),
			STAT_DATE				SMALLDATETIME
		)

		DECLARE @USRPackage Table
		(
			UP_ID			Int,
			UP_ID_USR		Int,
			UP_ID_SYSTEM	SmallInt,
			UP_DISTR		Int,
			UP_COMP			TinyInt,
			UP_RIC			SmallInt,
			UP_NET			SmallInt,
			UP_TECH			VarChar(20),
			UP_TYPE			VarChar(20),
			UP_FORMAT		SmallInt,
			Primary Key Clustered(UP_ID_USR, UP_ID_SYSTEM)
		);
		
		INSERT INTO @USRPackage
		SELECT Row_Number() OVER(ORDER BY UP_ID_SYSTEM), UP_ID_USR, UP_ID_SYSTEM, UP_DISTR, UP_COMP, UP_RIC, UP_NET, UP_TECH, UP_TYPE, UP_FORMAT
		FROM USR.USRPackage up
		--INNER JOIN Reg.RegNodeSearchView rnsw WITH(NOEXPAND) ON rnsw.DistrNumber = up.UP_DISTR AND up.UP_COMP = rnsw.CompNumber AND up.UP_ID_SYSTEM = rnsw.SystemID
		WHERE	UP_ID_USR = @UF_ID /*AND
				DS_REG = 0
			(
				SELECT TOP(1) DS_REG
				FROM Reg.RegNodeSearchView rnsw
				WHERE up.UP_DISTR = rnsw.DistrNumber AND up.UP_COMP = rnsw.CompNumber AND up.UP_ID_SYSTEM = rnsw.SystemID
			) = 0*/
	;
		
		SELECT @MaxRn = Max(UP_ID) FROM @USRPackage;
		
		SET @SystemXML =
		(
			SELECT
				[SYSTEMS] = 
					(
						SELECT
							Sys_Id		= P.UP_ID_SYSTEM,
							--Sys_Reg		= SystemBaseName,
							Net_Id		= N.NT_ID_MASTER
							--Net_Name	= DistrTypeName
						FROM @USRPackage P
						INNER JOIN Reg.RegNodeSearchView rnsw WITH(NOEXPAND) ON rnsw.DistrNumber = p.UP_DISTR AND 
																				p.UP_COMP = rnsw.CompNumber AND 
																				p.UP_ID_SYSTEM = rnsw.SystemID
						CROSS APPLY
						(
							SELECT TOP (1) NT_ID_MASTER
							FROM Din.NetType
							WHERE NT_TECH_USR = UP_TECH
								AND NT_NET = UP_NET
						) N
						WHERE rnsw.DS_REG = 0
						FOR XML RAW ('ITEM'), TYPE
					),
				[INFO_BANKS] = 
					(
						SELECT
							InfoBank_Id		= UI_ID_BASE
						FROM USR.USRIB
						WHERE UI_ID_USR = @UF_ID
						FOR XML RAW ('ITEM'), TYPE
					)
			FOR XML PATH(''), ROOT('ROOT')
		);
		
		INSERT INTO @IBs
		SELECT InfoBankId, InfoBankShortName
		FROM dbo.ComplectGetBanks(NULL, @SystemXML)
		
		SELECT @DAILY = ClientTypeDailyDay, @DAY = ClientTypeDay
		FROM 
			dbo.ClientTypeTable a 
			INNER JOIN dbo.ClientTable z ON a.ClientTypeID = z.CLientTypeID
		WHERE z.ClientID = @CLIENT

		INSERT INTO #tech_info(
				UIU_ID, UIU_ID_IB, UIU_INDX, UIU_DATE, UIU_DATE_S, 
				UIU_DOCS, UI_ID_BASE, UI_DISTR, UI_COMP, 
				UI_ID_COMP, USRFileKindShortName, STAT_DATE
				)
			SELECT 
				@MaxRn + Row_Number() OVER(ORDER BY UIU_ID_IB, UIU_INDX), UIU_ID_IB, IsNull(UIU_INDX, 1), UIU_DATE, UIU_DATE_S,
				UIU_DOCS, UI_ID_BASE, UI_DISTR, UI_COMP, 
				UI_ID_COMP, USRFileKindShortName, StatisticDate
				/*(
					SELECT TOP 1 StatisticDate
					FROM 
						dbo.StatisticTable a
					WHERE Docs = UIU_DOCS
						AND a.InfoBankID = UI_ID_BASE
						/*AND StatisticDate <= UIU_DATE*/
					ORDER BY StatisticDate DESC
				)*/
			FROM USR.USRIB
			LEFT JOIN USR.USRUpdates ON UI_ID = UIU_ID_IB
			LEFT JOIN dbo.USRFileKindTable ON UIU_ID_KIND = USRFileKindID
			OUTER APPLY
			(
				SELECT TOP 1 StatisticDate
				FROM 
					dbo.StatisticTable a
				WHERE Docs = UIU_DOCS
					AND a.InfoBankID = UI_ID_BASE
					/*AND StatisticDate <= UIU_DATE*/
				ORDER BY StatisticDate DESC
			) s
			WHERE UI_ID_USR = @UF_ID;

		SELECT @MaxRn = Max(UIU_ID) FROM #tech_info;

		UPDATE #tech_info
		SET STAT_DATE = dbo.FirstWorkDate(STAT_DATE)


		DECLARE @SQL NVARCHAR(MAX)

		SET @SQL = 'CREATE INDEX [IX_' + CONVERT(VARCHAR(50), NEWID()) + '] ON #tech_info (UIU_ID_IB, UIU_INDX) INCLUDE(UIU_DATE, UIU_DATE_S, UIU_DOCS)'
		EXEC (@SQL)
		
		SET @SQL = 'CREATE INDEX [IX_' + CONVERT(VARCHAR(50), NEWID()) + '] ON #tech_info (UIU_DATE) INCLUDE (UIU_ID_IB)'
		EXEC (@SQL)

		IF OBJECT_ID('tempdb..#usr') IS NOT NULL
			DROP TABLE #usr

		CREATE TABLE #usr
			(
				UI_ID_BASE		INT,
				UI_DISTR		INT,
				UI_COMP			TINYINT,
				UIU_DATE		SMALLDATETIME,
				UI_ID_COMP		INT
			)
		
		INSERT INTO #usr(UI_ID_BASE, UI_DISTR, UI_COMP, UIU_DATE, UI_ID_COMP)
			SELECT DISTINCT UI_ID_BASE, UI_DISTR, UI_COMP, UI_LAST, UI_ID_COMP
			FROM
				USR.USRFile
				INNER JOIN USR.USRIB ON UF_ID = UI_ID_USR 
			WHERE UF_ID_COMPLECT = @UD_ID			
				AND 
					(
						UF_MIN_DATE BETWEEN @MIN AND @MAX
						OR UF_MAX_DATE BETWEEN @MIN AND @MAX
					)

		SET @SQL = 'CREATE INDEX [IX_' + CONVERT(VARCHAR(50), NEWID()) + '] ON #usr (UI_ID_BASE, UI_DISTR, UI_COMP, UIU_DATE) INCLUDE(UI_ID_COMP)	'
		EXEC (@SQL)

		DECLARE @DS_ID	UNIQUEIDENTIFIER

		SELECT @DS_ID = DS_ID
		FROM dbo.DistrStatus
		WHERE DS_REG = 0

		DECLARE @UF_DATE DATETIME

		SELECT @UF_DATE = UF_DATE
		FROM USR.USRFile
		WHERE UF_ID = @UF_ID

		IF OBJECT_ID('tempdb..#package') IS NOT NULL
			DROP TABLE #package	

		CREATE TABLE #package
			(
				UP_ID			INT,
				UP_ID_USR		INT,
				UP_ID_SYSTEM	INT,
				UP_DISTR		INT,
				UP_COMP			TINYINT,
				UP_RIC			INT,
				UP_TECH			VARCHAR(20),
				UP_NET			INT,
				UP_TYPE			VARCHAR(20),
				UP_FORMAT		SMALLINT,
				InfoBankID		INT,
				InfoBankShortName	VARCHAR(20),
				InfoBankActual	BIT,
				InfoBankDaily	BIT,
				SystemShortName	VARCHAR(20),
				SystemBaseName	VARCHAR(20),
				SystemOrder		INT,
				InfoBankOrder	INT,
				HostID			INT,
				Required		SMALLINT
			)	

		INSERT INTO #package(
						UP_ID, UP_ID_USR, UP_ID_SYSTEM, UP_DISTR, UP_COMP, 
						UP_RIC, UP_TECH, UP_NET, UP_TYPE, UP_FORMAT,
						InfoBankID, InfoBankShortName, InfoBankActual, InfoBankDaily, 
						SystemShortName, SystemBaseName, SystemOrder, InfoBankOrder,
						HostID, Required
					)
			SELECT DISTINCT
				UP_ID, UP_ID_USR, UP_ID_SYSTEM, UP_DISTR, UP_COMP, 
				UP_RIC, UP_TECH, UP_NET, SST_SHORT AS UP_TYPE, UP_FORMAT,
				b.InfoBankID, b.InfoBankShortName, InfoBankActual, InfoBankDaily, 
				SystemShortName, SystemBaseName, SystemOrder, b.InfoBankOrder, HostID,			
				CASE d.InfoBankActive 
					WHEN 1 THEN 
						CASE 
							WHEN d.InfoBankStart > @UF_DATE THEN 0
							ELSE Required 
						END
					ELSE 0 
				END
			FROM 
				@USRPackage a
				INNER JOIN Din.NetType n ON a.UP_TECH = n.NT_TECH_USR AND a.UP_NET = n.NT_NET AND UP_TECH = NT_TECH_USR
				INNER JOIN dbo.DistrTypeTable t ON t.DistrTypeID = n.NT_ID_MASTER
				OUTER APPLY dbo.SystemBankGet(a.UP_ID_SYSTEM, n.NT_ID_MASTER) b
				INNER JOIN dbo.InfoBankTable d ON d.InfoBankID = b.InfoBankID
				LEFT OUTER JOIN Din.SystemType ON SST_REG = UP_TYPE
			WHERE UP_ID_USR = @UF_ID /*AND Required IN (0, 1)*/
				--AND SystemBaseCheck = 1
				AND DistrTypeBaseCheck = 1
				AND NOT EXISTS
					(
						SELECT *
						FROM 
							@USRPackage p
							INNER JOIN Din.NetType t ON p.UP_TECH = t.NT_TECH_USR AND p.UP_NET = t.NT_NET
							CROSS APPLY dbo.SystemBankGet(p.UP_ID_SYSTEM, t.NT_ID_MASTER) q
						WHERE p.UP_ID_USR = a.UP_ID_USR
							AND 
								(
									(b.InfoBankName = 'PSG' AND b.SystemBaseName = 'CMT' AND q.InfoBankName = 'PSG' AND q.SystemBaseName = 'BUD')
									OR
									(b.InfoBankName = 'PKG' AND b.SystemBaseName = 'CMT' AND q.InfoBankName = 'PKG' AND q.SystemBaseName = 'BUD')
									OR
									(b.InfoBankName = 'PPVS' AND b.SystemBaseName = 'CMT' AND q.InfoBankName = 'PPVS' AND q.SystemBaseName = 'BUD')
									OR
									(b.InfoBankName = 'BRB' AND b.SystemBaseName = 'MBP' AND q.InfoBankName = 'ARB' AND q.SystemBaseName = 'MBP')
									--OR
									--(b.InfoBankName = 'DOF' /*AND b.SystemBaseName = 'MBP'*/ AND q.InfoBankName = 'PAP' /*AND q.SystemBaseName = 'MBP'*/)
									OR
									(b.InfoBankName = 'EPB' AND q.InfoBankName = 'EXP')
									--OR
									--(b.InfoBankName = 'BRB' AND q.InfoBankName = 'ARB')
								)
					)
			
			UNION ALL
			
			SELECT 
				UP_ID, UP_ID_USR, UP_ID_SYSTEM, UP_DISTR, UP_COMP, 
				UP_RIC, UP_TECH, UP_NET, SST_SHORT AS UP_TYPE, UP_FORMAT,
				b.InfoBankID, b.InfoBankShortName, InfoBankActual, InfoBankDaily, 
				SystemShortName, SystemBaseName, z.SystemOrder, b.InfoBankOrder, HostID,			
				CASE d.InfoBankActive 
					WHEN 1 THEN 
						CASE 
							WHEN b.InfoBankStart > @UF_DATE THEN 0
							ELSE 1
						END
					ELSE 0 
				END
			FROM 
				@USRPackage a 
				INNER JOIN dbo.SystemTable z ON z.SystemID = UP_ID_SYSTEM
				INNER JOIN dbo.DistrConditionView b ON a.UP_ID_SYSTEM = b.SystemID 
																	AND a.UP_DISTR = b.DistrNumber 
																	AND a.UP_COMP = b.CompNumber
				INNER JOIN dbo.InfoBankTable d ON d.InfoBankID = b.InfoBankID
				LEFT OUTER JOIN Din.SystemType ON SST_REG = UP_TYPE
			WHERE UP_ID_USR = @UF_ID
			
			
			UNION ALL
			
			SELECT 
				UP_ID, UP_ID_USR, UP_ID_SYSTEM, UP_DISTR, UP_COMP, 
				UP_RIC, UP_TECH, UP_NET, SST_SHORT AS UP_TYPE, UP_FORMAT,
				NULL, NULL, NULL, NULL, 
				SystemShortName, SystemBaseName, z.SystemOrder, NULL, HostID, 0
			FROM 
				@USRPackage a 
				INNER JOIN dbo.SystemTable z ON z.SystemID = UP_ID_SYSTEM
				LEFT OUTER JOIN Din.SystemType ON SST_REG = UP_TYPE
			WHERE UP_ID_USR = @UF_ID;
			
			
			--DELETE FROM #package WHERE InfoBankId NOT IN (SELECT InfoBankId FROM @IBs);
			
			-- докидываем в дерево все остальные иб из файла usr, независимо от справочников
			INSERT INTO #package(
						UP_ID, UP_ID_USR, UP_ID_SYSTEM, UP_DISTR, UP_COMP, 
						UP_RIC, UP_TECH, UP_NET, UP_TYPE, UP_FORMAT,
						InfoBankID, InfoBankShortName, InfoBankActual, InfoBankDaily, 
						SystemShortName, SystemBaseName, SystemOrder, InfoBankOrder,
						HostID, Required
					)
			SELECT 
				UP_ID, UI_ID_USR, SYS.UP_ID_SYSTEM, UI_DISTR, UI_COMP,
				UP_RIC, UP_TECH, UP_NET, UP_TYPE, UP_FORMAT,
				InfoBankID, InfoBankShortName, InfoBankActual, InfoBankDaily,
				SystemShortName, SystemBaseName, SystemOrder, InfoBankOrder,
				HostId, 0
			FROM USR.USRIB
			INNER JOIN dbo.InfoBankTable ON UI_ID_BASE = InfoBankID
			OUTER APPLY
			(
				SELECT TOP 1 UP_ID, UP_ID_SYSTEM, UP_RIC, UP_TECH, UP_NET, UP_TYPE, UP_FORMAT, SystemShortName, SystemBaseName, SystemOrder, HostId
				FROM #package 
				WHERE UP_ID_SYSTEM IS NOT NULL
				ORDER BY CASE WHEN UI_DISTR = UP_DISTR THEN 1 ELSE 100 END, SystemOrder
			) AS SYS
			WHERE UI_ID_USR = @UF_ID
				AND NOT EXISTS
				(
					SELECT *
					FROM #package
					WHERE InfoBankId = UI_ID_BASE
						AND UP_DISTR = UI_DISTR
						AND UP_COMP = UI_COMP
				)

		SET @SQL = 'CREATE INDEX [IX_' + CONVERT(VARCHAR(50), NEWID()) + '] ON #package (InfoBankID, UP_DISTR, UP_COMP) INCLUDE(UP_ID, InfoBankShortName, SystemOrder, InfoBankOrder)'
		EXEC (@SQL)

		SELECT		
			UP_ID AS ID,
			NULL AS ID_MASTER,
			dbo.DistrString(SystemShortName, UP_DISTR, UP_COMP) + 
			CASE UP_RIC
				WHEN 20 THEN ''
				ELSE '/' + CONVERT(VARCHAR(20), UP_RIC)
			END + '/' + 
			CASE
				WHEN UP_TECH = 'FLS' THEN 'Флеш-версия'
				WHEN UP_TECH = 'OVKF' THEN 'ОВК-Ф'
				WHEN UP_TECH = 'OVMF' THEN 'ОВМ-Ф'
				WHEN UP_TECH = 'OVS' THEN 'ОВС'-- + CONVERT(VARCHAR(20), UP_NET)
				ELSE
					CASE UP_NET
						WHEN 0 THEN 'лок'
						WHEN 1 THEN '1/с'
						ELSE 'сеть ' + CONVERT(VARCHAR(20), UP_NET)
					END
			END + '/' + UP_TYPE + '/' + 
			CASE Service
				WHEN 0 THEN 'сопровождается'
				WHEN 1 THEN 'не сопровождается'
				ELSE 'не найден'
			END AS IB_NAME,
			Service,		
			NULL AS UIU_DAY,
			NULL AS UIU_DOCS,		
			NULL AS UIU_DATE,
			NULL AS ComplianceTypeShortName,
			NULL AS USRFileKindShortName, 		
			NULL AS StandartDate,
			NULL AS Standart,		

			UP_FORMAT,
			SystemOrder, 
			NULL AS InfoBankOrder,
			1 AS DATA_TYPE
		FROM 
			(
				SELECT DISTINCT 
						UP_ID, SystemShortName, SystemBaseName, SystemOrder, 
						UP_DISTR, UP_COMP, UP_RIC, UP_NET, UP_TECH, UP_TYPE, UP_FORMAT,
						Reg.DistrStatusGet(HostID, UP_DISTR, UP_COMP, @UF_DATE) AS Service
				FROM #package
			) b /*LEFT OUTER JOIN
			dbo.RegNodeTable f ON f.SystemName = b.SystemBaseName 
								AND f.DistrNumber = UP_DISTR 
								AND f.CompNumber = UP_COMP
			*/

		UNION

		/*
			Недостающие в USR системы
		*/
		SELECT
			@MaxRn + Row_Number() OVER(ORDER BY SystemOrder) AS ID,
			NULL AS ID_MASTER,
			dbo.DistrString(SystemShortName, DISTR, COMP) + '/' + NT_SHORT AS IB_NAME,
			-1 AS Service,		
			NULL AS UIU_DAY,
			NULL AS UIU_DOCS,		
			NULL AS UIU_DATE,
			NULL AS ComplianceTypeShortName,
			NULL AS USRFileKindShortName, 		
			NULL AS StandartDate,
			NULL AS Standart,		
			NULL AS UP_FORMAT,
			SystemOrder, 
			NULL AS InfoBankOrder,
			2 AS DATA_TYPE
		FROM 
			(
				SELECT DISTINCT Reg.RegComplectGet(HostID, UP_DISTR, UP_COMP, @UF_DATE) AS COMPLECT
				FROM #package
			) b 
			CROSS APPLY Reg.Complect@Periodic(b.COMPLECT, @UF_DATE) d
			INNER JOIN dbo.SystemTable ON ID_SYSTEM = SystemID
			INNER JOIN Din.NetType ON ID_NET = NT_ID
		WHERE SystemBaseName <> 'KDG'
			AND D.ID_STATUS = @DS_ID
			AND NOT EXISTS
			(
				SELECT *
				FROM #package
				WHERE UP_ID_SYSTEM = SystemID
					AND UP_DISTR = DISTR
					AND UP_COMP = COMP
			)

		
		UNION

		SELECT DISTINCT
			UIU_ID AS ID,
			UP_ID AS ID_MASTER,
			InfoBankShortName AS IB_NAME,
			NULL AS Service,		
			CONVERT(VARCHAR(20), UIU_DATE, 104) + ' ' + 
				CONVERT(VARCHAR(20), UIU_DATE, 108) + ' (' + 
				DATENAME(WEEKDAY, UIU_DATE) + ')' AS UIU_DAY, 
			CONVERT(VARCHAR(20), UIU_DOCS) + 
				REPLICATE(' ', 8 - LEN(CONVERT(VARCHAR(20), UIU_DOCS))) AS UIU_DOCS,
			UIU_DATE,
			ComplianceTypeShortName,
			USRFileKindShortName,
		
			STAT_DATE,
			CASE 
				WHEN InfoBankActual = 0 THEN 'Да'
				WHEN STAT_DATE IS NULL THEN 'Нет'
				WHEN
					CASE InfoBankActual
						WHEN 0 THEN DATEADD(DAY, 1, UIU_DATE_S)
						ELSE
							CASE InfoBankDaily
								WHEN 1 THEN dbo.WorkDaysAdd(STAT_DATE, @DAILY) 
								ELSE dbo.WorkDaysAdd(STAT_DATE, @DAY) 
							END
					END < UIU_DATE_S THEN 'Нет'
				ELSE 'Да'
			END,

			NULL AS UP_FORMAT,
			SystemOrder, 
			InfoBankOrder,
			3 AS DATA_TYPE
		FROM #tech_info
		INNER JOIN #package ON UI_DISTR = UP_DISTR AND UI_COMP = UP_COMP AND UI_ID_BASE = InfoBankID
		LEFT JOIN dbo.ComplianceTypeTable ON ComplianceTypeID = UI_ID_COMP		
		WHERE UIU_INDX = 1

		UNION

		/*
			Недостающие в USR ИБ
		*/
		SELECT
			@MaxRn + 100 + Row_Number() OVER(ORDER BY SystemOrder, InfoBankOrder) AS ID,
			UP_ID AS ID_MASTER,
			InfoBankShortName AS IB_NAME,
			-2 AS Service,		
			NULL AS UIU_DAY, 
			NULL AS UIU_DOCS,
			NULL UIU_DATE,
			NULL ComplianceTypeShortName,
			NULL USRFileKindShortName,
		
			NULL STAT_DATE,
			NULL,
			NULL AS UP_FORMAT,
			SystemOrder, 
			InfoBankOrder,
			4 AS DATA_TYPE
		FROM 
			#package P
		WHERE Required = 1
			AND InfoBankId IN (SELECT I.InfoBank_Id FROM @IBs I)
			AND NOT EXISTS
				(
					SELECT *
					FROM #tech_info
					WHERE UI_ID_BASE = InfoBankID
						AND UIU_INDX = 1
				)	

		UNION

		SELECT
			UIU_ID AS ID,
			(
				SELECT TOP 1 UIU_ID
				FROM 
					#tech_info r INNER JOIN
					#package ON UI_DISTR = UP_DISTR AND UI_COMP = UP_COMP AND UI_ID_BASE = InfoBankID
				WHERE UIU_INDX = 1 AND r.UIU_ID_IB = q.UIU_ID_IB
				ORDER BY UIU_ID
			) AS ID_MASTER,
			InfoBankShortName AS IB_NAME,
			NULL AS Service,		
			CONVERT(VARCHAR(20), UIU_DATE, 104) + ' ' + 
				CONVERT(VARCHAR(20), UIU_DATE, 108) + ' (' + 
				DATENAME(WEEKDAY, UIU_DATE) + ')' AS UIU_DAY, 
			CONVERT(VARCHAR(20), UIU_DOCS) + 
				REPLICATE(' ', 8 - LEN(CONVERT(VARCHAR(20), UIU_DOCS))) AS UIU_DOCS,
			UIU_DATE,
			(
				SELECT TOP 1 ComplianceTypeShortName
				FROM 
					#usr x INNER JOIN
					dbo.ComplianceTypeTable ON ComplianceTypeID = UI_ID_COMP
				WHERE x.UIU_DATE = q.UIU_DATE
					AND x.UI_ID_BASE = q.UI_ID_BASE
					AND x.UI_DISTR = q.UI_DISTR
					AND x.UI_COMP = q.UI_COMP
				ORDER BY ComplianceTypeOrder
			) AS ComplianceTypeShortName,
			USRFileKindShortName, 	

			STAT_DATE,
			CASE 
				WHEN InfoBankActual = 0 THEN 'Да'
				WHEN STAT_DATE IS NULL THEN 'Нет'
				WHEN
					CASE InfoBankActual
						WHEN 0 THEN DATEADD(DAY, 1, UIU_DATE_S)
						ELSE
							CASE InfoBankDaily
								WHEN 1 THEN dbo.WorkDaysAdd(STAT_DATE, @DAILY) 
								ELSE dbo.WorkDaysAdd(STAT_DATE, @DAY) 
							END
					END < UIU_DATE_S THEN 'Нет'
				ELSE 'Да'
			END,
				
			NULL AS UP_FORMAT,
			SystemOrder, 
			InfoBankOrder,
			5 AS DATA_TYPE
		FROM 
			#package a INNER JOIN
			#tech_info q ON a.InfoBankID = q.UI_ID_BASE AND a.UP_DISTR = q.UI_DISTR AND a.UP_COMP = q.UI_COMP
		WHERE UIU_INDX <> 1
		
		ORDER BY SystemOrder, InfoBankOrder, IB_NAME, UIU_DATE DESC

		IF OBJECT_ID('tempdb..#tech_info') IS NOT NULL
			DROP TABLE #tech_info

		IF OBJECT_ID('tempdb..#usr') IS NOT NULL
			DROP TABLE #usr

		IF OBJECT_ID('tempdb..#package') IS NOT NULL
			DROP TABLE #package
			
		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();
		
		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;
		
		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END

