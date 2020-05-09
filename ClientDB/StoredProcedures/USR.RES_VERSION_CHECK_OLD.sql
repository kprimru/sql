USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [USR].[RES_VERSION_CHECK_OLD]
	@MANAGER	INT,
	@SERVICE	INT,
	@DATE		SMALLDATETIME,
	@STATUS		VARCHAR(MAX),
	@ACTUAL		BIT,
	@CUSTOM		BIT,
	@RLIST		VARCHAR(MAX),
	@CLIST		VARCHAR(MAX),
	@KLIST		VARCHAR(MAX) = NULL
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

		IF OBJECT_ID('tempdb..#status') IS NOT NULL
			DROP TABLE #status

		CREATE TABLE #status
			(
				ST_ID	INT
			)

		IF @STATUS IS NOT NULL
			INSERT INTO #status(ST_ID)
				SELECT ID
				FROM dbo.TableIDFromXML(@STATUS)
		ELSE
			INSERT INTO #status(ST_ID)
				SELECT 2


		IF OBJECT_ID('tempdb..#client') IS NOT NULL
			DROP TABLE #client

		CREATE TABLE #client
			(
				CL_ID	INT	PRIMARY KEY
			)

		INSERT INTO #client(CL_ID)
			SELECT ClientID
			FROM
				dbo.ClientView WITH(NOEXPAND)
				INNER JOIN #status ON ST_ID = ServiceStatusID
			WHERE (ServiceID = @SERVICE OR @SERVICE IS NULL)
				AND (ManagerID = @MANAGER OR @MANAGER IS NULL)

		IF OBJECT_ID('tempdb..#res') IS NOT NULL
			DROP TABLE #res

		IF OBJECT_ID('tempdb..#cons') IS NOT NULL
			DROP TABLE #cons

		IF OBJECT_ID('tempdb..#kd') IS NOT NULL
			DROP TABLE #kd

		CREATE TABLE #res
			(
				RES_ID	INT
			)

		CREATE TABLE #cons
			(
				CONS_ID	INT
			)

		CREATE TABLE #kd
			(
				KD_ID	UNIQUEIDENTIFIER
			)


		IF @ACTUAL = 1
		BEGIN
			INSERT INTO #res(RES_ID)
				SELECT ResVersionID
				FROM dbo.ResVersionTable
				WHERE IsLatest = 1

			INSERT INTO #cons(CONS_ID)
				SELECT ConsExeVersionID
				FROM dbo.ConsExeVersionTable
				WHERE ConsExeVersionActive = 1

			INSERT INTO #kd(KD_ID)
				SELECT ID
				FROM dbo.KDVersion
				WHERE ACTIVE = 1
		END
		ELSE IF @CUSTOM = 1
		BEGIN
			INSERT INTO #res(RES_ID)
				SELECT ID
				FROM dbo.TableIDFromXML(@RLIST)

			INSERT INTO #cons(CONS_ID)
				SELECT ID
				FROM dbo.TableIDFromXML(@CLIST)

			INSERT INTO #kd(KD_ID)
				SELECT ID
				FROM dbo.TableGUIDFromXML(@KLIST)
		END

		SELECT
			ClientID, ClientFullName, ManagerName, ServiceName, rnsw.Complect,
			CASE WHEN RES_ID IS NULL THEN ResVersionShort ELSE '' END AS ResVersionNumber,
			CASE WHEN CONS_ID IS NULL THEN ConsExeVersionName ELSE '' END AS ConsExeVersionName,
			/*CASE WHEN KD_ID IS NULL THEN SHORT ELSE '' END */ '' AS KDVersionName,
			UF_DATE, UF_CREATE
		FROM
			USR.USRComplectCurrentStatusView a WITH(NOEXPAND)
			INNER JOIN Reg.RegNodeSearchView rnsw WITH(NOEXPAND) ON a.UD_DISTR = rnsw.DistrNumber AND a.UD_COMP = rnsw.CompNumber AND a.UD_SYS = rnsw.SystemID AND rnsw.DS_REG = 0
			INNER JOIN USR.USRActiveView b ON a.UD_ID = b.UD_ID
			INNER JOIN USR.USRFileTech t ON b.UF_ID = t.UF_ID
			INNER JOIN #client c ON c.CL_ID = b.UD_ID_CLIENT
			INNER JOIN dbo.ClientView d WITH(NOEXPAND) ON c.CL_ID = d.ClientID
			INNER JOIN dbo.ResVersionTable e ON e.ResVersionID = t.UF_ID_RES
			INNER JOIN dbo.ConsExeVersionTable f ON t.UF_ID_CONS = ConsExeVersionID
			LEFT OUTER JOIN dbo.KDVersion g ON t.UF_ID_KDVERSION = g.ID
			LEFT OUTER JOIN #res ON RES_ID = t.UF_ID_RES
			LEFT OUTER JOIN #cons ON CONS_ID = t.UF_ID_CONS
			LEFT OUTER JOIN #kd ON KD_ID = t.UF_ID_KDVERSION
		WHERE UD_SERVICE = 0
			AND (UF_DATE >= @DATE OR @DATE IS NULL)
			AND (RES_ID IS NULL OR CONS_ID IS NULL /*OR KD_ID IS NULL*/)
		ORDER BY ManagerName, ServiceName, ClientFullName, UD_NAME

		IF OBJECT_ID('tempdb..#res') IS NOT NULL
			DROP TABLE #res

		IF OBJECT_ID('tempdb..#cons') IS NOT NULL
			DROP TABLE #cons

		IF OBJECT_ID('tempdb..#kd') IS NOT NULL
			DROP TABLE #kd

		IF OBJECT_ID('tempdb..#client') IS NOT NULL
			DROP TABLE #client

		IF OBJECT_ID('tempdb..#status') IS NOT NULL
			DROP TABLE #status

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [USR].[RES_VERSION_CHECK_OLD] TO rl_old_res_version;
GO