USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[USR].[CLIENT_SYSTEM_AUDIT (NEW)]', 'P ') IS NULL EXEC('CREATE PROCEDURE [USR].[CLIENT_SYSTEM_AUDIT (NEW)]  AS SELECT 1')
GO
CREATE OR ALTER PROCEDURE [USR].[CLIENT_SYSTEM_AUDIT (NEW)]
	@MANAGER	INT = NULL,
	@SERVICE	INT = NULL,
	@IB			NVARCHAR(MAX) = NULL,
	@DATE		SMALLDATETIME = NULL,
	@CLIENT		INT = NULL
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

		DECLARE @Clients Table
		(
			ClientId		Int,
			Complect		VarChar(100),
			ComplectStr		VarChar(100)
			Primary Key Clustered(ClientId, Complect)
		);

		DECLARE @ClientsDistrs Table
		(
			ClientId		Int,
			Complect		VarChar(100),
			ComplectStr		VarChar(100),
			DistrStr		VarChar(100),
			HostId			SmallInt,
			SystemId		SmallInt,
			DistrTypeId		SmallInt,
			Distr			Int,
			Comp			TinyInt,
			DisStr			VarChar(100)
		);

		INSERT INTO @Clients
		SELECT a.ClientId, t.Complect, t.ComplectStr
		FROM dbo.ClientView a WITH(NOEXPAND)
		CROSS APPLY
		(
			SELECT
				Complect,
				ComplectStr = DistrStr
			FROM dbo.RegNodeComplectClientView t
			WHERE ClientID = a.ClientId
				AND DS_REG = 0
		) t
		WHERE ServiceStatusID = 2
			AND (ManagerID = @manager OR @manager IS NULL)
			AND (ServiceID = @service OR @service IS NULL)
			AND (a.CLientID = @CLIENT OR @CLIENT IS NULL);

		INSERT INTO @ClientsDistrs
		SELECT c.ClientId, c.Complect, c.ComplectStr, b.DistrStr, b.HostId, b.SystemId, b.DistrTypeId, b.Distr, b.Comp, b.DistrStr
		FROM @Clients c
		INNER JOIN dbo.ClientDistrView b WITH(NOEXPAND) ON c.ClientID = b.ID_CLIENT
		INNER JOIN Reg.RegNodeSearchView r WITH(NOEXPAND) ON b.Distr = r.DistrNumber AND b.Comp = r.CompNumber AND b.HostId = r.HostId AND r.Complect = c.Complect
		WHERE SystemBaseCheck = 1
			AND DistrTypeBaseCheck = 1
			AND b.DS_REG = 0
			AND b.SystemBaseName NOT IN ('RGU')
		OPTION (RECOMPILE);

		IF OBJECT_ID('tempdb..#info_bank') IS NOT NULL
			DROP TABLE #info_bank

		DECLARE @info_bank Table
		(
			ClientId			Int,
			Complect			VarChar(100),
			ComplectStr			VarChar(100),
			DistrStr			VarChar(100),
			Distr				Int,
			Comp				TinyInt,
			SystemId			SmallInt,
			InfoBankId			SmallInt,
			InfoBankStart		SmallDateTime,
			Primary Key Clustered(ClientId,Complect,SystemId,InfoBankId)
		);

		INSERT INTO @info_bank(ClientID, Complect, ComplectStr, DistrStr, Distr, Comp, SystemId, InfoBankID, InfoBankStart)
		SELECT DISTINCT a.ClientID, Complect, ComplectStr, DistrStr, DISTR, COMP, SystemId, InfoBankID, InfoBankStart
		FROM
		(
			SELECT
				a.ClientID, a.Complect, a.ComplectStr, DistrStr, DISTR, COMP, a.SystemId, c.InfoBankID, InfoBankStart, InfoBankName, SystemBaseName
			FROM @ClientsDistrs a
			CROSS APPLY dbo.SystemBankGet(a.SystemId, a.DistrTypeId) c
			WHERE 	InfoBankActive = 1
				AND Required = 1

			UNION

			SELECT
				a.ClientID, a.Complect, a.ComplectStr, DistrStr, DISTR, COMP, a.SystemId, c.InfoBankID, InfoBankStart, InfoBankName, SystemBaseName
			FROM @ClientsDistrs a
			INNER JOIN dbo.DistrConditionView c ON a.SystemID = c.SystemID
												AND a.DISTR = c.DistrNumber
												AND a.COMP = c.CompNumber
			INNER JOIN dbo.SystemTable s ON s.SystemId = a.SystemId
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
					FROM @ClientsDistrs p
					CROSS APPLY dbo.SystemBankGet(p.SystemId, p.DistrTypeId) q
					WHERE p.ClientId = a.ClientId
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
								(a.InfoBankName = 'CJI' AND a.SystemBaseName = 'CMT' AND q.InfoBankName = 'CJI' AND q.SystemBaseName = 'BUD')
								OR
								(a.InfoBankName = 'CMB' AND a.SystemBaseName = 'CMT' AND q.InfoBankName = 'CMB' AND q.SystemBaseName = 'BUD')
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
		OPTION (RECOMPILE);

		DECLARE @usr Table
		(
			UF_ID		Int,
			UF_DATE		DateTime,
			Primary Key Clustered(UF_ID)
		);

		INSERT INTO @usr(UF_ID, UF_DATE)
		SELECT UF_ID, UF_DATE
		FROM USR.USRActiveView
		INNER JOIN
		(
			SELECT DISTINCT ClientID
			FROM @info_bank
		) AS o_O ON ClientID = UD_ID_CLIENT


		DECLARE @ib_out Table
		(
			ID					INT IDENTITY(1,1),
			ClientID			INT,
			ManagerName			NVARCHAR(450),
			ServiceName			NVARCHAR(450),
			ClientFullName		NVARCHAR(450),
			ComplectStr			NVARCHAR(450),
			DisStr				NVARCHAR(450),
			InfoBankName		NVARCHAR(200),
			InfoBankShortName	NVARCHAR(200),
			LAST_DATE			DATETIME,
			UF_DATE				DATETIME
			Primary Key Clustered(ID)
		);


		INSERT INTO @ib_out(ClientID, ManagerName, ServiceName, ClientFullName, ComplectStr, DisStr, InfoBankName, InfoBankShortName, LAST_DATE, UF_DATE)
		SELECT
			c.ClientID, ManagerName, ServiceName, ClientFullName, ComplectStr,
			DisStr = DistrStr,
			InfoBankName,
			InfoBankShortName,
			LAST_DATE, UF_DATE
		FROM
		(
			SELECT
				a.ClientID, a.ComplectStr, DistrStr, SystemId, InfoBankId,
				(
					SELECT TOP 1 UI_LAST
					FROM
						USR.USRIB z
						INNER JOIN USR.USRFile y ON y.UF_ID = z.UI_ID_USR
						INNER JOIN USR.USRData x ON x.UD_ID = y.UF_ID_COMPLECT
					WHERE UD_ID_CLIENT = a.ClientID
						AND UI_ID_BASE = a.InfoBankID
						AND UI_DISTR = Distr
						AND UI_COMP = Comp
					ORDER BY UF_DATE DESC
				) AS LAST_DATE,
				(
					SELECT TOP 1 UF_DATE
					FROM USR.USRActiveView
					WHERE UD_ID_CLIENT = ClientID
					ORDER BY UF_DATE DESC
				) AS UF_DATE
			FROM @info_bank a
			WHERE NOT EXISTS
					(
						-- тут добавить комплект?
						SELECT *
						FROM
							@usr z INNER JOIN
							USR.USRIB ON UI_ID_USR = UF_ID
						WHERE InfoBankId = UI_ID_BASE
							AND UI_DISTR = a.Distr
							AND UI_COMP = a.Comp
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
		INNER JOIN dbo.ClientView c ON o_O.ClientId = c.ClientId
		INNER JOIN dbo.SystemTable s ON o_O.SystemId = s.SystemId
		INNER JOIN dbo.InfoBankTable i ON o_O.InfoBankId = i.InfoBankId
		WHERE @DATE IS NULL OR UF_DATE > @DATE
		ORDER BY ManagerName, ServiceName, ClientFullName, SystemOrder, InfoBankOrder
		OPTION (RECOMPILE);

		SELECT
			ClientID, ManagerName, ServiceName, ClientFullName, ComplectStr,
			ComplectStr AS DisStr,
			REVERSE(STUFF(REVERSE((
				SELECT
					InfoBankShortName + ', '
				FROM
					@ib_out b
				WHERE
					a.ComplectStr = b.ComplectStr
				FOR XML PATH('')
			)), 1, 2, '')) AS InfoBankShortName,
			/*REVERSE(STUFF(REVERSE((
				SELECT
					InfoBankName + ', '
				FROM
					@ib_out b
				WHERE
					a.ComplectStr = b.ComplectStr
				FOR XML PATH('')
			)), 1, 2, '')) AS InfoBankName,  */
			Max(LAST_DATE) AS LAST_DATE, UF_DATE
		FROM @ib_out a
		GROUP BY ClientID, ManagerName, ServiceName, ClientFullName, ComplectStr, /*DisStr, LAST_DATE, */UF_DATE

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
