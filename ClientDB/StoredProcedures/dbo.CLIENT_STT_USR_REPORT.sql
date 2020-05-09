USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[CLIENT_STT_USR_REPORT]
	@BEGIN		SMALLDATETIME,
	@END		SMALLDATETIME,
	@SERVICE	INT,
	@MANAGER	NVARCHAR(MAX),
	@HIDE		BIT,
	@TOTAL		BIT = 0,
	@UNGET		BIT = 0
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

		SET @END = DATEADD(DAY, 1, @END)

		IF @SERVICE IS NOT NULL
			SET @MANAGER = NULL

		IF OBJECT_ID('tempdb..#result') IS NOT NULL
			DROP TABLE #result

		CREATE TABLE #result
			(
				ClientID		INT PRIMARY KEY,
				ClientFullName	VARCHAR(500),
				ManagerName		VARCHAR(150),
				ServiceName		VARCHAR(150),
				USR_COUNT		INT,
				STT_COUNT		INT
			)

		INSERT INTO #result(ClientID, ClientFullName, ManagerName, ServiceName, USR_COUNT, STT_COUNT)
			SELECT
				ClientID, ClientFullName, ManagerName, ServiceName,
				(
					SELECT COUNT(*)
					FROM
						USR.USRData z
						INNER JOIN USR.USRFile y ON UF_ID_COMPLECT = z.UD_ID
					WHERE z.UD_ID_CLIENT = a.ClientID
						AND UD_ACTIVE = 1
						AND UF_ACTIVE = 1
						AND (UF_PATH = 0 OR UF_PATH = 3)
						AND UF_DATE BETWEEN @BEGIN AND @END
				) AS USR_COUNT,
				(
					SELECT COUNT(*)
					FROM
						dbo.ClientStat z
						INNER JOIN dbo.SystemTable x ON x.SystemNumber = z.SYS_NUM
						INNER JOIN dbo.ClientDistrView y WITH(NOEXPAND) ON z.DISTR = y.DISTR AND z.COMP = y.COMP AND x.SystemID = y.SystemID
					WHERE y.ID_CLIENT = ClientID
						AND DATE BETWEEN @BEGIN AND @END
				) AS STT_COUNT
			FROM
				dbo.ClientView a WITH(NOEXPAND)
				INNER JOIN [dbo].[ServiceStatusConnected]() s ON a.ServiceStatusId = s.ServiceStatusId
			WHERE	(a.ServiceID = @SERVICE OR @SERVICE IS NULL)
				AND (a.ManagerID IN (SELECT ID FROM dbo.TableIDFromXML(@MANAGER)) OR @MANAGER IS NULL)
			ORDER BY ManagerName, ServiceName, ClientFullName
		/*
		IF @HIDE = 1
			DELETE FROM #result WHERE USR_COUNT = 0
			*/

		IF @TOTAL = 0
			SELECT
				ClientID, ClientFullName, ManagerName, ServiceName, USR_COUNT, STT_COUNT,
				ClientCount, ACTIVE_COUNT, ERROR_COUNT,
				ROUND(CASE ACTIVE_COUNT
					WHEN 0 THEN 0
					ELSE ROUND(100 * CONVERT(FLOAT, ERROR_COUNT) / ACTIVE_COUNT, 2)
				END, 2) AS ERROR_PERCENT,
				ROUND(ACTIVE_COUNT - ERROR_COUNT, 2) AS NORMAL_COUNT,
				ROUND(100 - CASE ACTIVE_COUNT
					WHEN 0 THEN 0
					ELSE ROUND(100 * CONVERT(FLOAT, ERROR_COUNT) / ACTIVE_COUNT, 2)
				END, 2) AS NORMAL_PERCENT,
				LAST_UPDATE
			FROM
				(
					SELECT
						ClientID, ClientFullName, ManagerName, ServiceName, USR_COUNT, STT_COUNT,
						(
							SELECT COUNT(*)
							FROM #result b
							WHERE a.ServiceName = b.ServiceName
						) AS ClientCount,
						(
							SELECT COUNT(*)
							FROM #result b
							WHERE a.ServiceName = b.ServiceName
								AND USR_COUNT <> 0
						) AS ACTIVE_COUNT,
						(
							SELECT COUNT(*)
							FROM #result b
							WHERE a.ServiceName = b.ServiceName
								AND USR_COUNT <> 0 AND STT_COUNT = 0
						) AS ERROR_COUNT,
						(
							SELECT TOP 1 UIU_DATE_S
							FROM USR.USRIBDateView WITH(NOEXPAND)
							WHERE UD_ID_CLIENT = ClientID
							ORDER BY UIU_DATE_S DESC
						) AS LAST_UPDATE
					FROM #result a
					WHERE ((USR_COUNT <> 0 AND @HIDE = 1) OR (@HIDE = 0))
						AND (USR_COUNT <> 0 AND STT_COUNT = 0 AND @UNGET = 1 OR @UNGET = 0)
				) AS o_O
			ORDER BY ManagerName, ServiceName, ClientFullName
		ELSE
			SELECT
				ManagerName, ServiceName,
				ClientCount, ACTIVE_COUNT, ERROR_COUNT,
				ROUND(CASE ACTIVE_COUNT
					WHEN 0 THEN 0
					ELSE ROUND(100 * CONVERT(FLOAT, ERROR_COUNT) / ACTIVE_COUNT, 2)
				END, 2) AS ERROR_PERCENT,
				ROUND(ACTIVE_COUNT - ERROR_COUNT, 2) AS NORMAL_COUNT,
				ROUND(100 - CASE ACTIVE_COUNT
					WHEN 0 THEN 0
					ELSE ROUND(100 * CONVERT(FLOAT, ERROR_COUNT) / ACTIVE_COUNT, 2)
				END, 2) AS NORMAL_PERCENT,
				NULL AS LAST_UPDATE
			FROM
				(
					SELECT DISTINCT
						ManagerName, ServiceName,
						(
							SELECT COUNT(*)
							FROM #result b
							WHERE a.ServiceName = b.ServiceName
						) AS ClientCount,
						(
							SELECT COUNT(*)
							FROM #result b
							WHERE a.ServiceName = b.ServiceName
								AND USR_COUNT <> 0
						) AS ACTIVE_COUNT,
						(
							SELECT COUNT(*)
							FROM #result b
							WHERE a.ServiceName = b.ServiceName
								AND USR_COUNT <> 0 AND STT_COUNT = 0
						) AS ERROR_COUNT
					FROM #result a
				) AS o_O
			ORDER BY ManagerName, ServiceName

		IF OBJECT_ID('tempdb..#result') IS NOT NULL
			DROP TABLE #result

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END

GO
GRANT EXECUTE ON [dbo].[CLIENT_STT_USR_REPORT] TO rl_usr_stt_report;
GO