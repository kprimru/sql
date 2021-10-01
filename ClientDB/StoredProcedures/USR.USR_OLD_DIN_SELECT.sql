USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [USR].[USR_OLD_DIN_SELECT]
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

		IF @SERVICE IS NOT NULL
			SET @MANAGER = NULL

		IF OBJECT_ID('tempdb..#client') IS NOT NULL
			DROP TABLE #client

		CREATE TABLE #client (CL_ID INT PRIMARY KEY)

		INSERT INTO #client(CL_ID)
			SELECT ClientID
			FROM dbo.ClientView WITH(NOEXPAND)
			WHERE ServiceStatusID = 2
				AND (ManagerID = @MANAGER OR @MANAGER IS NULL)
				AND (ServiceID = @SERVICE OR @SERVICE IS NULL)

		IF OBJECT_ID('tempdb..#usr') IS NOT NULL
			DROP TABLE #usr

		CREATE TABLE #usr(UD_ID_CLIENT INT, UD_NAME VARCHAR(50), UF_DATE SMALLDATETIME, UP_ID_SYSTEM INT, UP_DISTR INT, UP_COMP TINYINT, UP_FORMAT SMALLINT)

		INSERT INTO #usr(UD_ID_CLIENT, UD_NAME, UF_DATE, UP_ID_SYSTEM, UP_DISTR, UP_COMP, UP_FORMAT)
			SELECT UD_ID_CLIENT, dbo.DistrString(s.SystemShortName, UD_DISTR, UD_COMP), UF_DATE, UP_ID_SYSTEM, UP_DISTR, UP_COMP, UP_FORMAT
			FROM
				#client
				INNER JOIN USR.USRActiveView z ON UD_ID_CLIENT = CL_ID
				INNER JOIN dbo.SystemTable s ON s.SystemID = z.UF_ID_SYSTEM
				INNER JOIN USR.USRPackage y ON y.UP_ID_USR = z.UF_ID
			WHERE UD_ACTIVE = 1 AND UF_ACTIVE = 1

		DECLARE @SQL VARCHAR(MAX)

		SET @SQL = 'CREATE INDEX [IX_' + CONVERT(VARCHAR(50), NEWID()) + '] ON #usr (UP_DISTR, UP_COMP, UP_ID_SYSTEM, UD_ID_CLIENT) INCLUDE (UD_NAME, UF_DATE, UP_FORMAT)'
		EXEC (@SQL)

		SELECT
			ManagerName, ServiceName, ClientFullName, DistrStr AS DisStr,
			UF_DATE,
			CASE UP_FORMAT
				WHEN 0 THEN 'Не заменен'
				WHEN 1 THEN 'Заменен'
				ELSE 'Неизвестно'
			END AS UP_RESULT, UD_NAME
		FROM
			#client
			INNER JOIN dbo.ClientDistrView a WITH(NOEXPAND) ON a.ID_CLIENT = CL_ID
			INNER JOIN dbo.ClientView b WITH(NOEXPAND) ON a.ID_CLIENT = b.ClientID
			LEFT OUTER JOIN #usr d ON d.UD_ID_CLIENT = a.ID_CLIENT
							AND UP_ID_SYSTEM = a.SystemID
							AND UP_DISTR = DISTR
							AND UP_COMP = COMP
			LEFT OUTER JOIN
				(
					SELECT RPR_ID_HOST, RPR_DISTR, RPR_COMP, dbo.DateOf(RPR_DATE) AS RPR_DATE
					FROM dbo.RegProtocol e
					WHERE RPR_OPER = 'НОВАЯ'
				) AS e ON e.RPR_ID_HOST = a.HostID AND RPR_DISTR = UP_DISTR AND RPR_COMP = UP_COMP
		WHERE DS_REG = 0 AND ISNULL(UP_FORMAT, 0) = 0 AND (RPR_DATE <= DATEADD(MONTH, -1, dbo.DateOf(GETDATE())) OR RPR_DATE IS NULL)
		ORDER BY ManagerName, ServiceName, ClientFullName, SystemOrder, DISTR


		IF OBJECT_ID('tempdb..#client') IS NOT NULL
			DROP TABLE #client

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
