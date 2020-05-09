USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[CLIENT_SEARCH]
	@NAME		VARCHAR(500) = NULL,
	@SERVICE	INT = NULL,
	@SYSTEM		INT = NULL,
	@DISTR		INT = NULL,
	@RSERVICE	INT = 0,
	@RMANAGER	INT = 0,
	@STATUS		INT = NULL,
	@MANAGER	INT = NULL,
	@STYPE		INT	= NULL,
	@REG		BIT = NULL,
	@COMPL		BIT = NULL,
	@NET		INT = NULL
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

		DECLARE @DIS	VARCHAR(50)

		SET @DIS = CONVERT(VARCHAR(20), @DISTR) + '%'

		IF OBJECT_ID('tempdb..#client') IS NOT NULL
			DROP TABLE #client

		CREATE TABLE #client
			(
				CL_ID INT PRIMARY KEY
			)

		INSERT INTO #client(CL_ID)
			SELECT WCL_ID
			FROM [dbo].[ClientList@Get?Read]()

		IF @NAME IS NOT NULL
			DELETE FROM #client
			WHERE CL_ID NOT IN
				(
					SELECT ClientID
					FROM dbo.ClientTable
					WHERE ClientFullName LIKE @NAME
						OR EXISTS
							(
								SELECT *
								FROM dbo.ClientNames
								WHERE ID_CLIENT = ClientID
									AND NAME LIKE @NAME
							)
				)

		IF @SERVICE IS NOT NULL
			DELETE FROM #client
			WHERE CL_ID NOT IN
				(
					SELECT ClientID
					FROM dbo.ClientTable
					WHERE ClientServiceID = @SERVICE
				)

		IF @STATUS IS NOT NULL
			DELETE FROM #client
			WHERE CL_ID NOT IN
				(
					SELECT ClientID
					FROM dbo.ClientTable
					WHERE StatusID = @STATUS
				)

		IF @MANAGER IS NOT NULL
			DELETE FROM #client
			WHERE CL_ID NOT IN
				(
					SELECT ClientID
					FROM
						dbo.ClientTable
						INNER JOIN dbo.ServiceTable ON ServiceID = ClientServiceID
					WHERE ManagerID = @MANAGER
				)

		IF @STYPE IS NOT NULL
			DELETE FROM #client
			WHERE CL_ID NOT IN
				(
					SELECT ClientID
					FROM dbo.ClientTable
					WHERE ServiceTypeID = @STYPE
				)

		IF (@SYSTEM IS NOT NULL) OR (@DISTR IS NOT NULL) OR (@NET IS NOT NULL)
		BEGIN
			DELETE FROM #client
			WHERE CL_ID NOT IN
				(
					SELECT ID_CLIENT
					FROM dbo.ClientDistrView WITH(NOEXPAND)
					WHERE ((SystemID = @SYSTEM) OR (@SYSTEM IS NULL))
						AND (DistrTypeID = @NET OR @NET IS NULL)
						AND ((CONVERT(VARCHAR(20), DISTR) LIKE @DIS) OR @DIS IS NULL)
				)
		END

		IF @RSERVICE <> 0
			DELETE FROM #client
			WHERE CL_ID NOT IN
				(
					SELECT ClientID
					FROM dbo.ClientTable
					WHERE ClientServiceID = @RSERVICE
				)

		IF @RMANAGER <> 0
			DELETE FROM #client
			WHERE CL_ID NOT IN
				(
					SELECT ClientID
					FROM
						dbo.ClientTable a 
						INNER JOIN dbo.ServiceTable ON ServiceID = ClientServiceID
					WHERE ManagerID = @RMANAGER
				)

		IF @COMPL = 1
			DELETE
			FROM #client
			WHERE CL_ID NOT IN
				(
					SELECT a.UD_ID_CLIENT
					FROM
						USR.USRActiveView a
						INNER JOIN USR.USRComplianceView b WITH(NOEXPAND) ON a.UF_ID = b.UF_ID
					WHERE UF_ACTIVE = 1 AND UD_ACTIVE = 1 AND a.UD_ID_CLIENT IS NOT NULL
						AND UF_COMPLIANCE = '#HOST'
				)


		IF (@REG = 1) AND ((IS_MEMBER('rl_tech_reg') = 1) OR (IS_SRVROLEMEMBER('sysadmin') = 1))
		BEGIN
			SELECT
				a.ClientID, 'OIS' AS TP, a.ClientFullName, CA_STR AS ClientAdress,
				ServiceName, ManagerName, a.ServiceStatusIndex
			FROM
				#client
				INNER JOIN dbo.ClientView a WITH(NOEXPAND) ON a.ClientID = CL_ID
				INNER JOIN dbo.ClientTable b ON b.ClientID = a.ClientID
				INNER JOIN dbo.ServiceStatusTable d ON d.ServiceStatusID = a.ServiceStatusID
				LEFT OUTER JOIN dbo.ClientAddressView e ON e.CA_ID_CLIENT = a.ClientID AND AT_REQUIRED = 1

			UNION ALL

			SELECT
				ID, 'REG' AS TP, Comment, '',
				'', '', (SELECT TOP 1 ServiceStatusIndex FROM dbo.ServiceStatusTable WHERE ServiceStatusReg = Service ORDER BY ServiceStatusIndex)
			FROM
				Reg.RegNodeSearchView a WITH(NOEXPAND)
				INNER JOIN
					(
						SELECT DISTINCT Complect
						FROM Reg.RegNodeSearchView a WITH(NOEXPAND)
						WHERE Complect IS NOT NULL
							/*AND NOT EXISTS
								(
									SELECT *
									FROM
										dbo.ClientDistrView c WITH(NOEXPAND)
									WHERE c.SystemBaseName = a.SystemName
										AND a.DistrNumber = c.DISTR
										AND a.CompNumber = c.COMP
								)
								*/
					) AS b ON a.Complect = b.Complect AND b.Complect LIKE a.SystemBaseName + '%'
			WHERE (a.Comment LIKE @NAME OR @NAME IS NULL)
				AND (a.DistrNumber LIKE @DISTR OR @DISTR IS NULL)


			UNION ALL

			SELECT
				ID, 'REG' AS TP, Comment, '',
				'', '', (SELECT TOP 1 ServiceStatusIndex FROM dbo.ServiceStatusTable WHERE ServiceStatusReg = Service ORDER BY ServiceStatusIndex)
			FROM Reg.RegNodeSearchView a WITH(NOEXPAND)
			WHERE Complect IS NULL
				AND (Comment LIKE @NAME OR @NAME IS NULL)
				AND (DistrNumber LIKE @DISTR OR @DISTR IS NULL)
				AND NOT EXISTS
				(
					SELECT *
					FROM
						dbo.ClientDistrView c
					WHERE c.SystemBaseName = a.SystemBaseName
						AND a.DistrNumber = c.DISTR
						AND a.CompNumber = c.COMP
				)
			ORDER BY ClientFullName
		END
		ELSE
		BEGIN
			SELECT
				a.ClientID, 'OIS' AS TP, a.ClientFullName, CONVERT(VARCHAR(250), CA_STR) AS ClientAdress,
				ServiceName, ManagerName, a.ServiceStatusIndex
			FROM
				#client
				INNER JOIN dbo.ClientView a WITH(NOEXPAND) ON a.ClientID = CL_ID
				INNER JOIN dbo.ClientTable b ON b.ClientID = a.ClientID
				INNER JOIN dbo.ServiceStatusTable d ON d.ServiceStatusID = a.ServiceStatusID
				LEFT OUTER JOIN dbo.ClientAddressView e ON e.CA_ID_CLIENT = a.ClientID AND AT_REQUIRED = 1
			ORDER BY ClientFullName
		END

		IF OBJECT_ID('tempdb..#client') IS NOT NULL
			DROP TABLE #client

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [dbo].[CLIENT_SEARCH] TO BL_ADMIN;
GRANT EXECUTE ON [dbo].[CLIENT_SEARCH] TO BL_EDITOR;
GRANT EXECUTE ON [dbo].[CLIENT_SEARCH] TO BL_PARAM;
GRANT EXECUTE ON [dbo].[CLIENT_SEARCH] TO BL_READER;
GRANT EXECUTE ON [dbo].[CLIENT_SEARCH] TO BL_RGT;
GRANT EXECUTE ON [dbo].[CLIENT_SEARCH] TO rl_client_list;
GRANT EXECUTE ON [dbo].[CLIENT_SEARCH] TO rl_tech_info;
GO