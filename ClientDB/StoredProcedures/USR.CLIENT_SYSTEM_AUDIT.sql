USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [USR].[CLIENT_SYSTEM_AUDIT]
	@MANAGER	INT = NULL,
	@SERVICE	INT = NULL,
	@IB			NVARCHAR(MAX) = NULL,
	@DATE		SMALLDATETIME = NULL,
	@CLIENT		INT = NULL
AS
BEGIN
	SET NOCOUNT ON;

	EXEC [USR].[CLIENT_SYSTEM_AUDIT (NEW)]
		@Manager	= @Manager,
		@Service	= @Service,
		@IB			= @IB,
		@Date		= @Date,
		@Client		= @Client;

	RETURN;

	IF OBJECT_ID('tempdb..#info_bank') IS NOT NULL
		DROP TABLE #info_bank

	CREATE TABLE #info_bank
		(
			CLientID	INT,
			ManagerName	VARCHAR(100),
			ServiceName	VARCHAR(100),
			ClientFullName	VARCHAR(250),
			DisStr		VARCHAR(50),
			InfoBankShortName	VARCHAR(50),
			SystemDistrNumber	INT,
			CompNumber		TINYINT,
			InfoBankName	VARCHAR(50),
			InfoBankOrder	INT,
			SystemOrder		INT,
			InfoBankID		INT,
			InfoBankStart	SMALLDATETIME
		)

	INSERT INTO #info_bank(CLientID, ManagerName, ServiceName, ClientFullName,
			DisStr, InfoBankShortName, SystemDistrNumber, CompNumber, InfoBankName,
			InfoBankOrder, SystemOrder, InfoBankID, InfoBankStart)
		SELECT 
			a.ClientID, ManagerName, ServiceName, 
			ClientFullName, 
			DistrStr,
			InfoBankShortName,
			DISTR, COMP, InfoBankName,
			InfoBankOrder, SystemOrder, InfoBankID, InfoBankStart
		FROM 
			(
				SELECT 
					a.ClientID, ManagerName, ServiceName, ClientFullName, DistrStr,
					InfoBankShortName, DISTR, COMP, InfoBankName, c.InfoBankOrder, c.SystemOrder, 
					c.InfoBankID, InfoBankStart, b.SystemBaseName
				FROM
					dbo.ClientView a WITH(NOEXPAND)
					INNER JOIN dbo.ClientDistrView b WITH(NOEXPAND) ON a.ClientID = b.ID_CLIENT 
					--INNER JOIN dbo.SystemBanksView c WITH(NOEXPAND) ON c.SystemID = b.SystemID			
					CROSS APPLY dbo.SystemBankGet(b.SystemId, b.DistrTypeId) c
				WHERE ServiceStatusID = 2 
					AND SystemBaseCheck = 1
					AND DistrTypeBaseCheck = 1
					AND (ManagerID = @manager OR @manager IS NULL)
					AND (ServiceID = @service OR @service IS NULL)
					AND (a.CLientID = @CLIENT OR @CLIENT IS NULL)
					AND b.SystemBaseName NOT IN (/*'RGN', */'RGU')
					AND DS_REG = 0
					AND InfoBankActive = 1
					AND Required = 1
					
				UNION ALL
				
				SELECT 
					a.ClientID, ManagerName, ServiceName, ClientFullName, DistrStr,
					InfoBankShortName, DISTR, COMP, InfoBankName, InfoBankOrder, b.SystemOrder, 
					InfoBankID, InfoBankStart, b.SystemBaseName
				FROM
					dbo.ClientView a WITH(NOEXPAND)
					INNER JOIN dbo.ClientDistrView b WITH(NOEXPAND) ON a.ClientID = b.ID_CLIENT
					INNER JOIN dbo.DistrConditionView c ON b.SystemID = c.SystemID 
																	AND DISTR = DistrNumber 
																	AND COMP = CompNumber	
				WHERE ServiceStatusID = 2 
					AND SystemBaseCheck = 1
					AND DistrTypeBaseCheck = 1
					AND (ManagerID = @manager OR @manager IS NULL)
					AND (ServiceID = @service OR @service IS NULL)
					AND (a.CLientID = @CLIENT OR @CLIENT IS NULL)
					AND b.SystemBaseName NOT IN (/*'RGN', */'RGU')
					AND DS_REG = 0
			) AS a
		WHERE 
			(
				@IB IS NULL OR 
				InfoBankID IN 
					(
						SELECT ID
						FROM dbo.TableIDFromXML(@IB)
					)
			)
			AND
			NOT EXISTS
				(
					SELECT *
					FROM
						dbo.ClientDistrView p WITH(NOEXPAND)
						--INNER JOIN dbo.SystemBanksView q WITH(NOEXPAND) ON q.SystemID = p.SystemID						
						CROSS APPLY dbo.SystemBankGet(p.SystemId, p.DistrTypeId) q --WITH(NOEXPAND) ON q.SystemID = p.SystemID						
					WHERE p.ID_CLIENT = a.ClientID 
						/*
						AND a.DISTR = p.DISTR
						AND a.COMP = p.COMP
						*/
						AND p.DS_REG = 0
						AND 
							(
								(a.InfoBankName = 'BRB' AND q.InfoBankName = 'ARB') 								
								OR
								(a.InfoBankName = 'DOF' AND q.InfoBankName = 'PAP')
								OR
								(a.InfoBankName = 'EPB' AND q.InfoBankName = 'EXP')
								OR
								
								(a.InfoBankName = 'PBI' AND a.SystemBaseName = 'FIN' AND q.InfoBankName = 'PBI' AND q.SystemBaseName = 'BUDP')
								OR
								(a.InfoBankName = 'QSA' AND a.SystemBaseName = 'FIN' AND q.InfoBankName = 'QSA' AND q.SystemBaseName = 'BUDP')
								OR
								(a.InfoBankName = 'BCN' AND a.SystemBaseName = 'FIN' AND q.InfoBankName = 'BCN' AND q.SystemBaseName = 'BUDP')
								OR
								(a.InfoBankName = 'BMS' AND a.SystemBaseName = 'FIN' AND q.InfoBankName = 'BMS' AND q.SystemBaseName = 'BUDP')
								OR
								(a.InfoBankName = 'BRB' AND a.SystemBaseName = 'FIN' AND q.InfoBankName = 'BRB' AND q.SystemBaseName = 'BUDP')
								OR
								(a.InfoBankName = 'BSZ' AND a.SystemBaseName = 'FIN' AND q.InfoBankName = 'BSZ' AND q.SystemBaseName = 'BUDP')
								OR
								(a.InfoBankName = 'BVS' AND a.SystemBaseName = 'FIN' AND q.InfoBankName = 'BVS' AND q.SystemBaseName = 'BUDP')
								OR
								(a.InfoBankName = 'BZS' AND a.SystemBaseName = 'FIN' AND q.InfoBankName = 'BZS' AND q.SystemBaseName = 'BUDP')
								OR
								(a.InfoBankName = 'PPS' AND a.SystemBaseName = 'FIN' AND q.InfoBankName = 'PPS' AND q.SystemBaseName = 'BUDP')
								OR
								(a.InfoBankName = 'PKV' AND a.SystemBaseName = 'FIN' AND q.InfoBankName = 'PKV' AND q.SystemBaseName = 'BUDP')
								OR
								(a.InfoBankName = 'PPN' AND a.SystemBaseName = 'FIN' AND q.InfoBankName = 'PPN' AND q.SystemBaseName = 'BUDP')
								OR
								(a.InfoBankName = 'BDV' AND a.SystemBaseName = 'FIN' AND q.InfoBankName = 'BDV' AND q.SystemBaseName = 'BUDP')
								OR
								(a.InfoBankName = 'BPV' AND a.SystemBaseName = 'FIN' AND q.InfoBankName = 'BPV' AND q.SystemBaseName = 'BUDP')
								OR
								(a.InfoBankName = 'BSK' AND a.SystemBaseName = 'FIN' AND q.InfoBankName = 'BSK' AND q.SystemBaseName = 'BUDP')
								OR
								(a.InfoBankName = 'BUR' AND a.SystemBaseName = 'FIN' AND q.InfoBankName = 'BUR' AND q.SystemBaseName = 'BUDP')
								OR
								(a.InfoBankName = 'BVV' AND a.SystemBaseName = 'FIN' AND q.InfoBankName = 'BVV' AND q.SystemBaseName = 'BUDP')
								OR								
								(a.InfoBankName = 'PSG' AND a.SystemBaseName = 'CMT' AND q.InfoBankName = 'PSG' AND q.SystemBaseName = 'BUD')
								OR
								(a.InfoBankName = 'PKG' AND a.SystemBaseName = 'CMT' AND q.InfoBankName = 'PKG' AND q.SystemBaseName = 'BUD')
								OR
								(a.InfoBankName = 'PPVS' AND a.SystemBaseName = 'CMT' AND q.InfoBankName = 'PPVS' AND q.SystemBaseName = 'BUD')
								OR
								(a.InfoBankName = 'PKV' AND a.SystemBaseName = 'FIN' AND q.InfoBankName = 'PKV' AND q.SystemBaseName = 'BUD')
								OR
								(a.InfoBankName = 'PKV' AND a.SystemBaseName = 'QSA' AND q.InfoBankName = 'PKV' AND q.SystemBaseName = 'BUD')
								OR
								(a.InfoBankName = 'BCN' AND (q.InfoBankName = 'ACN' OR q.InfoBankName = 'SCN' OR q.InfoBankName = 'NCN'))
								OR
								(a.InfoBankName = 'BDV' AND (q.InfoBankName = 'ADV' OR q.InfoBankName = 'SDV' OR q.InfoBankName = 'NDV'))
								OR
								(a.InfoBankName = 'BMS' AND (q.InfoBankName = 'AMS' OR q.InfoBankName = 'SMS' OR q.InfoBankName = 'NMS'))
								OR
								(a.InfoBankName = 'BPV' AND (q.InfoBankName = 'APV' OR q.InfoBankName = 'SPV' OR q.InfoBankName = 'NPV'))
								OR
								(a.InfoBankName = 'BSK' AND (q.InfoBankName = 'ASK' OR q.InfoBankName = 'SSK' OR q.InfoBankName = 'NSK'))
								OR
								(a.InfoBankName = 'BSZ' AND (q.InfoBankName = 'ASZ' OR q.InfoBankName = 'SSZ' OR q.InfoBankName = 'NSZ'))
								OR
								(a.InfoBankName = 'BVS' AND (q.InfoBankName = 'AVS' OR q.InfoBankName = 'SVS' OR q.InfoBankName = 'NVS'))
								OR
								(a.InfoBankName = 'BVV' AND (q.InfoBankName = 'AVV' OR q.InfoBankName = 'SVV' OR q.InfoBankName = 'NVV'))
								OR
								(a.InfoBankName = 'BZS' AND (q.InfoBankName = 'AZS' OR q.InfoBankName = 'SZS' OR q.InfoBankName = 'NZS'))
								OR
								(a.InfoBankName = 'BUR' AND (q.InfoBankName = 'AUR' OR q.InfoBankName = 'SUR' OR q.InfoBankName = 'NUR'))
							)
			)

	DECLARE @SQL NVARCHAR(MAX)

	SET @SQL = 'CREATE CLUSTERED INDEX [IX_' + CONVERT(VARCHAR(50), NEWID()) + '] ON #info_bank (ClientID, InfoBankName, SystemDistrNumber, CompNumber)'
	EXEC (@SQL)

	IF OBJECT_ID('tempdb..#usr') IS NOT NULL
		DROP TABLE #usr
	
	CREATE TABLE #usr
		(
			UF_ID	UNIQUEIDENTIFIER,
			UF_DATE	DATETIME
		)

	INSERT INTO #usr(UF_ID, UF_DATE)
		SELECT UF_ID, UF_DATE
		FROM 
			USR.USRActiveView
			INNER JOIN 
				(
					SELECT DISTINCT ClientID 
					FROM #info_bank 
				) AS o_O ON ClientID = UD_ID_CLIENT
			
	SET @SQL = 'CREATE CLUSTERED INDEX [IX_' + CONVERT(VARCHAR(50), NEWID()) + '] ON #usr (UF_ID)'
	EXEC (@SQL)

	SELECT 
		ClientID, ManagerName, ServiceName, ClientFullName, 
		DisStr, InfoBankShortName, 
		LAST_DATE, UF_DATE
	FROM
		(
			SELECT 
				a.ClientID, ManagerName, ServiceName, ClientFullName, 
				DisStr, InfoBankShortName, InfoBankOrder, SystemOrder,
				(
					SELECT TOP 1 UI_LAST
					FROM 
						USR.USRIB z
						INNER JOIN USR.USRFile y ON y.UF_ID = z.UI_ID_USR
						INNER JOIN USR.USRData x ON x.UD_ID = y.UF_ID_COMPLECT
					WHERE UD_ID_CLIENT = a.ClientID
						AND UI_ID_BASE = a.InfoBankID
						AND UI_DISTR = SystemDistrNumber
						AND UI_COMP = CompNumber
					ORDER BY UF_DATE DESC
				) AS LAST_DATE,
				(
					SELECT MAX(UF_DATE)
					FROM USR.USRActiveView
					WHERE UD_ID_CLIENT = ClientID
				) AS UF_DATE
			FROM #info_bank a
			WHERE NOT EXISTS
					(
						SELECT *
						FROM 
							#usr z INNER JOIN
							USR.USRIB ON UI_ID_USR = UF_ID INNER JOIN
							dbo.InfoBankTable y ON InfoBankID = UI_ID_BASE
						WHERE y.InfoBankName = a.InfoBankName
							AND UI_DISTR = SystemDistrNumber
							AND UI_COMP = CompNumber
							AND (UF_DATE > InfoBankStart OR InfoBankStart IS NULL)
					)
				AND EXISTS
					(
						SELECT *
						FROM USR.USRActiveView z
						WHERE z.UD_ID_CLIENT = a.ClientID
							AND UD_ACTIVE = 1
					)
		) AS o_O
	WHERE @DATE IS NULL OR UF_DATE > @DATE
	ORDER BY ManagerName, ServiceName, ClientFullName, SystemOrder, InfoBankOrder	

	IF OBJECT_ID('tempdb..#info_bank') IS NOT NULL
		DROP TABLE #info_bank	
	
	IF OBJECT_ID('tempdb..#usr') IS NOT NULL
		DROP TABLE #usr
	
	IF OBJECT_ID('tempdb..#info_bank') IS NOT NULL
		DROP TABLE #info_bank
END