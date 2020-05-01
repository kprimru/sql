USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[CLIENT_SERVICE_TYPE_AUDIT]
	@MANAGER	INT,
	@SERVICE	INT
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

		DECLARE @BEGIN	SMALLDATETIME
		DECLARE @END	SMALLDATETIME

		SET @END = DATEADD(DAY, 1, CONVERT(SMALLDATETIME, CONVERT(VARCHAR(20), GETDATE(), 112), 112))
		SET @BEGIN = DATEADD(MONTH, -1, @END)

		IF OBJECT_ID('tempdb..#update') IS NOT NULL
			DROP TABLE #update

		CREATE TABLE #update
			(
				CL_ID		INT,
				ServiceType	INT,
				UD_NAME		VARCHAR(50),
				USRService	SMALLINT,
				USRRobot	SMALLINT,
				USRIP		SMALLINT
			)

		INSERT INTO #update(CL_ID, ServiceType, UD_NAME, USRService, USRRobot, USRIP)
			SELECT
				ClientID, ServiceTypeID, dbo.DistrString(s.SystemShortName, b.UD_DISTR, b.UD_COMP),
				(
					SELECT COUNT(*)
					FROM USR.USRFile
					WHERE UF_ID_COMPLECT = b.UD_ID
						AND UF_DATE < @END AND UF_DATE >= @BEGIN
						AND UF_PATH = 0
				) AS USRService,
				(
					SELECT COUNT(*)
					FROM USR.USRFile
					WHERE UF_ID_COMPLECT = b.UD_ID
						AND UF_DATE < @END AND UF_DATE >= @BEGIN
						AND UF_PATH = 1
				) AS USRRobot,
				(
					SELECT COUNT(*)
					FROM USR.USRFile
					WHERE UF_ID_COMPLECT = b.UD_ID
						AND UF_DATE < @END AND UF_DATE >= @BEGIN
						AND UF_PATH = 2
				) AS USRIP
			FROM
				dbo.ClientTable a
				INNER JOIN [dbo].[ServiceStatusConnected]() t ON a.StatusId = t.ServiceStatusId
				INNER JOIN dbo.ServiceTable ON ServiceID = ClientServiceID
				INNER JOIN USR.USRData b ON UD_ID_CLIENT = ClientID
				INNER JOIN USR.USRComplectCurrentStatusView c WITH(NOEXPAND) ON b.UD_ID = c.UD_ID
				INNER JOIN USR.USRActiveView f ON f.UD_ID = b.UD_ID
				INNER JOIN dbo.SystemTable s ON s.SystemID = f.UF_ID_SYSTEM
			WHERE UD_SERVICE = 0
				AND a.STATUS = 1
				AND (ManagerID = @MANAGER OR @MANAGER IS NULL)
				AND (ClientServiceID = @SERVICE OR @SERVICE IS NULL)

		SELECT
			ManagerName, ServiceName, ClientFullName, ServiceTypeShortName AS ServiceTypeName,
			UD_NAME, USRService, USRRobot, USRIP, Verdict, CL_ID AS ClientID
		FROM
			(
				SELECT
					CL_ID, ServiceType, UD_NAME, USRService, USRRobot, USRIP,
					'Клиент сопровождается по Роботу' AS Verdict
				FROM #update
				WHERE ServiceType IN (1, 2, 6) AND USRRobot <> 0 AND USRIP = 0

				UNION ALL

				SELECT
					CL_ID, ServiceType, UD_NAME, USRService, USRRobot, USRIP,
					'Клиент сопровождается по ИП'
				FROM #update
				WHERE ServiceType IN (1, 2, 6) AND USRRobot = 0 AND USRIP <> 0

				UNION ALL

				SELECT
					CL_ID, ServiceType, UD_NAME, USRService, USRRobot, USRIP,
					'Клиент сопровождается и по Роботу и по ИП'
				FROM #update
				WHERE ServiceType IN (1, 2, 6)AND USRRobot <> 0 AND USRIP <> 0

				UNION ALL

				SELECT
						CL_ID, ServiceType, UD_NAME, USRService, USRRobot, USRIP,
					'Клиент сопровождается Сервис-инженером'
				FROM #update
				WHERE ServiceType = 3 AND USRService <> 0 AND USRRobot = 0 AND USRIP = 0

				UNION ALL

				SELECT
					CL_ID, ServiceType, UD_NAME, USRService, USRRobot, USRIP,
					'Клиент сопровождается по ИП'
				FROM #update
				WHERE ServiceType = 3 AND USRRobot = 0 AND USRIP <> 0

				UNION ALL

				SELECT
					CL_ID, ServiceType, UD_NAME, USRService, USRRobot, USRIP,
					'Клиент сопровождается и по Роботу и по ИП'
				FROM #update
				WHERE ServiceType = 3 AND USRRobot <> 0 AND USRIP <> 0

				UNION ALL

				SELECT
					CL_ID, ServiceType, UD_NAME, USRService, USRRobot, USRIP,
					'Клиент сопровождается Сервис-инженером'
				FROM #update
				WHERE ServiceType = 4 AND USRService <> 0 AND USRRobot = 0 AND USRIP = 0

				UNION ALL

				SELECT
					CL_ID, ServiceType, UD_NAME, USRService, USRRobot, USRIP,
					'Клиент сопровождается по Роботу'
				FROM #update
				WHERE ServiceType = 4 AND USRRobot <> 0 AND USRIP = 0

				UNION ALL

				SELECT
					CL_ID, ServiceType, UD_NAME, USRService, USRRobot, USRIP,
					'Клиент сопровождается и по Роботу и по ИП'
				FROM #update
				WHERE ServiceType = 4 AND USRRobot <> 0 AND USRIP <> 0
			) AS o_O
			INNER JOIN dbo.ClientTable a ON a.ClientID = o_O.CL_ID
			INNER JOIN dbo.ServiceTypeTable b ON b.ServiceTypeID = o_O.ServiceType
			INNER JOIN dbo.ServiceTable c ON c.ServiceID = a.ClientServiceID
			INNER JOIN dbo.ManagerTable d ON d.ManagerID = c.ManagerID
		ORDER BY ManagerName, ServiceName, ClientFullName, UD_NAME

		IF OBJECT_ID('tempdb..#update') IS NOT NULL
			DROP TABLE #update

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GRANT EXECUTE ON [dbo].[CLIENT_SERVICE_TYPE_AUDIT] TO rl_service_type_audit;
GO