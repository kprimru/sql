USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[SERVICE_ERROR_REPORT]
	@SERVICE	INT,
	@DATE		SMALLDATETIME,
	@MANAGER	VARCHAR(150) = NULL OUTPUT,
	@CNT		VARCHAR(100) = NULL OUTPUT
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

		SELECT @MANAGER = '������ �� ����������� ��������� ������ ' + ServiceName + '(' + ManagerName + ') �� ' + dbo.MonthString(GETDATE())
		FROM
			dbo.ServiceTable a
			INNER JOIN dbo.ManagerTable b ON a.ManagerID = b.ManagerID
		WHERE a.ServiceID = @SERVICE

		IF @DATE IS NULL
			SET @DATE = DATEADD(MONTH, -1, dbo.DateOf(GETDATE()))

		IF OBJECT_ID('tempdb..#check') IS NOT NULL
			DROP TABLE #check

		CREATE TABLE #check
			(
				CL_ID		INT,
				CL_NAME		VARCHAR(500),
				DISTR		VARCHAR(150),
				LAST_USR	SMALLDATETIME,
				TECH_DATA	VARCHAR(MAX),
				COMPLIANCE	VARCHAR(MAX),
				COMPLIANCE_DATE	SMALLDATETIME,
				IB			VARCHAR(MAX),
				IB_DATE		SMALLDATETIME,
				NOTE		VARCHAR(MAX),
				UNSERVICE	VARCHAR(MAX)
			)

		INSERT INTO #check(CL_ID, CL_NAME, DISTR, LAST_USR)
			SELECT DISTINCT
				ClientID, ClientFullName, Complect,
				dbo.DateOf((
					SELECT TOP 1 UF_DATE
					FROM USR.USRActiveView av
					INNER JOIN Reg.RegNodeSearchView rnsw2 WITH(NOEXPAND) ON rnsw2.DistrNumber = av.UD_DISTR
					WHERE	UD_ID_CLIENT = ClientID AND
							rnsw2.Complect = rnsw.Complect
					ORDER BY UF_DATE DESC
				))
			FROM dbo.ClientView cv WITH(NOEXPAND)
			INNER JOIN dbo.ClientDistrView cdv WITH(NOEXPAND) ON cdv.ID_CLIENT = cv.ClientID
			INNER JOIN Reg.RegNodeSearchView rnsw WITH(NOEXPAND) ON cdv.HostID = rnsw.HostID AND
																	cdv.DISTR = rnsw.DistrNumber AND
																	cdv.COMP = rnsw.CompNumber AND
																	rnsw.DS_REG = 0
			INNER JOIN [dbo].[ServiceStatusConnected]() s ON cv.ServiceStatusId = cv.ServiceStatusId
			WHERE ServiceID = @SERVICE;

		DECLARE @IB TABLE
			(
				ClientID			INT,
				Complect			VARCHAR(100),
				ManagerName			VARCHAR(50),
				ServiceName			VARCHAR(50),
				ClientFullName		VARCHAR(500),
				DisStr				VARCHAR(50),
				InfoBankShortName	VARCHAR(MAX),
				InfoBankCode		VARCHAR(MAX),
				LAST_DATE			DATETIME,
				UF_DATE				DATETIME,
				ServiceTypeName		VARCHAR(100),
				UsrFileKindShortName VARCHAR(100)
			)

		INSERT INTO @IB
			EXEC USR.CLIENT_SYSTEM_AUDIT NULL, @SERVICE, NULL, @DATE


		UPDATE a
		SET IB =
			REVERSE(STUFF(REVERSE(
				(
					SELECT InfoBankShortName + ','
					FROM @IB b
					WHERE b.Complect = a.DISTR
					FOR XML PATH('')
				)), 1, 1, '')),
			IB_DATE =
				dbo.DateOf(
					(
						SELECT MIN(LAST_DATE)
						FROM @IB b
						WHERE b.Complect = a.DISTR
							AND LAST_DATE IS NOT NULL
					))
		FROM #check a

		DECLARE @UNSERV TABLE
			(
			    UD_ID_CLIENT        Int,
				UF_CREATE			DATETIME,
				UF_DATE				DATETIME,
				Serviced			VARCHAR(1024),
				Unserviced			VARCHAR(1024),
				Complect			VARCHAR(50),
				ManagerName         VarChar(100),
				ServiceName         VarChar(100),
				ClientFullName      VarChar(512)
			)


		INSERT INTO @UNSERV
			EXEC USR.COMPLECT_UNSERVICE_SYSTEM NULL, @SERVICE, @DATE, 1


		UPDATE a
		SET UNSERVICE =
				REVERSE(STUFF(REVERSE(
				(
					SELECT Unserviced + ','
					FROM @UNSERV b
					WHERE a.DISTR = b.Complect
					FOR XML PATH('')
				)), 1, 1, ''))
		FROM #check a

		DECLARE @RES TABLE
			(
				ClientID				INT,
				ClientFullName			VARCHAR(500),
				ManagerName				VARCHAR(50),
				ServiceName				VARCHAR(50),
				Complect				VARCHAR(50),
				ResVersionNumber		VARCHAR(50),
				ConsExeVersionNumber	VARCHAR(50),
				KDVersionName			VARCHAR(50),
				UF_DATE					DATETIME,
				UF_CREATE				DATETIME
			)

		INSERT INTO @RES
			EXEC USR.RES_VERSION_CHECK NULL, @SERVICE, @DATE, NULL, 1, 0, NULL, NULL, NULL

		UPDATE a
		SET TECH_DATA =
			REVERSE(STUFF(REVERSE(
				(
					SELECT
						CASE ResVersionNumber WHEN '' THEN '' ELSE '�� : ' + ResVersionNumber + ',' END +
						CASE ConsExeVersionNumber WHEN '' THEN '' ELSE ' Cons.exe : ' + ConsExeVersionNumber + ',' END --+
						--CASE KDVersionName WHEN '' THEN '' ELSE ' �� : ' + KDVersionName + ',' END
					FROM @RES b
					WHERE a.DISTR = b.Complect
					FOR XML PATH('')
				)), 1, 1, ''))
		FROM #check a

		DECLARE @COMPLIANCE	TABLE
			(
				ClientID			INT,
				ClientFullName		VARCHAR(500),
				ManagerName			VARCHAR(50),
				ServiceName			VARCHAR(50),
				UD_NAME				VARCHAR(50),
				InfoBankShortName	VARCHAR(50),
				Complect			VARCHAR(50),
				FIRST_DATE			SMALLDATETIME,
				UIU_DATE			SMALLDATETIME
			)

		INSERT INTO @COMPLIANCE
			EXEC USR.USR_COMPLIANCE_LAST @DATE, NULL, @SERVICE

		UPDATE a
		SET COMPLIANCE =
			REVERSE(STUFF(REVERSE(
				(
					SELECT InfoBankShortName + ','
					FROM @COMPLIANCE b
					WHERE a.DISTR = b.Complect
					FOR XML PATH('')
				)
			), 1, 1, '')),
			COMPLIANCE_DATE =
					(
						SELECT dbo.DateOf(MIN(FIRST_DATE))
						FROM @COMPLIANCE b
						WHERE a.CL_ID = b.ClientID
							AND FIRST_DATE IS NOT NULL
					)
		FROM #check a

		SELECT @CNT =
				CONVERT(VARCHAR(20),
					(
						SELECT COUNT(*) FROM #check WHERE TECH_DATA IS NOT NULL OR IB IS NOT NULL OR COMPLIANCE IS NOT NULL
					))
				 + ' �� ' +
				CONVERT(VARCHAR(20),
					(
						SELECT COUNT(*) FROM #check
					))

		UPDATE #check
		SET NOTE =
			CASE
				WHEN IB_DATE IS NOT NULL THEN '�� � ' + CONVERT(VARCHAR(20), IB_DATE, 104) + ' '
				ELSE ''
			END +
			CASE
				WHEN COMPLIANCE_DATE IS NOT NULL THEN '���������� � ' + CONVERT(VARCHAR(20), COMPLIANCE_DATE, 104)
				ELSE ''
			END

		SELECT
			CL_ID, CL_NAME, DISTR, LAST_USR, TECH_DATA, COMPLIANCE, IB, NOTE, UNSERVICE,
			CASE
				WHEN TECH_DATA IS NULL AND COMPLIANCE IS NULL AND IB IS NULL AND UNSERVICE IS NULL THEN 1
				ELSE 0
			END AS NORM,
			(
				SELECT TOP 1 UIU_DATE_S
				FROM USR.USRIBDateView WITH(NOEXPAND)
				WHERE UD_ID_CLIENT = CL_ID
				ORDER BY UIU_DATE_S DESC
			) AS LAST_UPDATE
		FROM
			#check
		ORDER BY CL_NAME

		IF OBJECT_ID('tempdb..#check') IS NOT NULL
			DROP TABLE #check

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [dbo].[SERVICE_ERROR_REPORT] TO rl_service_error_report;
GO
