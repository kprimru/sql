USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[CLIENT_DUTY_REPORT]
	@BEGIN		SMALLDATETIME,
	@END		SMALLDATETIME,
	@SERVICE	INT,
	@MANAGER	INT,
	@NUM_BEGIN	INT = NULL,
	@NUM_END	INT = NULL,
	@ANS		BIT = NULL,
	@SAT		BIT = NULL
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

		IF @END IS NOT NULL
			SET @END = DATEADD(DAY, 1, @END)

		IF OBJECT_ID('tempdb..#client') IS NOT NULL
			DROP TABLE #client

		CREATE TABLE #client
			(
				ClientID		INT PRIMARY KEY,
				ClientFullName	VARCHAR(250),
				ServiceName		VARCHAR(150),
				ManagerName		VARCHAR(150),
				ConnectDate		SMALLDATETIME,
				DUTY_COUNT		INT,
				ANS_COUNT		INT,
				SAT_COUNT		INT
			)

		INSERT INTO #client(ClientID, ClientFullName, ServiceName, ManagerName, ConnectDate, DUTY_COUNT, ANS_COUNT, SAT_COUNT)
			SELECT 
				ClientID, ClientFullName, ServiceName, ManagerName,
				(
					SELECT MIN(ConnectDate)
					FROM dbo.ClientConnectView z WITH(NOEXPAND)
					WHERE z.ClientID = a.ClientID
				) AS ClientConnect,
				(
					SELECT COUNT(*)
					FROM dbo.ClientDutyTable z
					WHERE z.ClientID = a.ClientID
						AND STATUS = 1
						AND (z.ClientDutyDateTime >= @BEGIN OR @BEGIN IS NULL)
						AND (z.ClientDutyDateTime < @END OR @END IS NULL)
				) AS DUTY_COUNT,
				(
					SELECT COUNT(*)
					FROM 
						dbo.ClientDutyTable z
						INNER JOIN dbo.ClientDutyResult y ON z.ClientDutyID = y.ID_DUTY
					WHERE z.ClientID = a.ClientID
						AND z.STATUS = 1
						AND y.STATUS = 1
						AND ANSWER = 1
						AND (z.ClientDutyDateTime >= @BEGIN OR @BEGIN IS NULL)
						AND (z.ClientDutyDateTime < @END OR @END IS NULL)
				) AS ANS_COUNT,
				(
					SELECT COUNT(*)
					FROM 
						dbo.ClientDutyTable z
						INNER JOIN dbo.ClientDutyResult y ON z.ClientDutyID = y.ID_DUTY
					WHERE z.ClientID = a.ClientID
						AND z.STATUS = 1
						AND y.STATUS = 1
						AND SATISF = 1
						AND (z.ClientDutyDateTime >= @BEGIN OR @BEGIN IS NULL)
						AND (z.ClientDutyDateTime < @END OR @END IS NULL)
				) AS SAT_COUNT
			FROM dbo.ClientView a WITH(NOEXPAND)
			INNER JOIN [dbo].[ServiceStatusConnected]() s ON a.ServiceStatusId = s.ServiceStatusId
			WHERE	(ServiceID = @SERVICE OR @SERVICE IS NULL)
				AND (ManagerID = @MANAGER OR @MANAGER IS NULL)
		
					
		DELETE
		FROM #client
		WHERE (DUTY_COUNT < @NUM_BEGIN AND @NUM_BEGIN IS NOT NULL)
			OR (DUTY_COUNT > @NUM_END AND @NUM_END IS NULL)					
				
		IF @ANS = 1
			DELETE FROM #client WHERE ANS_COUNT = 0
		IF @SAT = 1
			DELETE FROM #client WHERE SAT_COUNT = 0
						
		SELECT 
			RN, ClientID, CLientFullName, ServiceName, ManagerName, ConnectDate, DUTY_COUNT, NOTE, NOTE_ALL,
			(
				SELECT TOP 1 DistrStr + ' (' + DistrTypeName + ')'
				FROM dbo.ClientDistrView WITH(NOEXPAND)
				WHERE ClientID = ID_CLIENT
					AND DS_REG = 0
				ORDER BY SystemOrder
			) AS MAIN_DISTR,
			ANS_COUNT, SAT_COUNT
		FROM
			(		
				SELECT 
					ROW_NUMBER() OVER(PARTITION BY ServiceName ORDER BY ClientFullName) AS RN,
					ClientID, ClientFullName, ServiceName, ManagerName, ConnectDate, DUTY_COUNT, ANS_COUNT, SAT_COUNT,
					'Итого клиентов без обращения в ДС: ' + 
						CONVERT(VARCHAR(20), 
							(
								SELECT COUNT(*)
								FROM #client z
								WHERE z.ServiceName = a.ServiceName
									AND DUTY_COUNT = 0
							)) + ' (' + 
							CONVERT(VARCHAR(20), 
								ROUND(CONVERT(FLOAT,
									(
										SELECT COUNT(*)
										FROM #client z
										WHERE z.ServiceName = a.ServiceName
											AND DUTY_COUNT = 0
									) * 100
								) /
								CONVERT(FLOAT,
									(
									SELECT COUNT(*)
									FROM #client z
									WHERE z.ServiceName = a.ServiceName
									)), 2)) + '%)' AS NOTE,
					(
						SELECT ISNULL(CONVERT(VARCHAR(20), DUTY_COUNT), 'Всего') + '     -     ' + CONVERT(VARCHAR(20), CNT) + CHAR(10)
						FROM
							(
								SELECT DISTINCT DUTY_COUNT, COUNT(*) AS CNT
								FROM #client
								GROUP BY DUTY_COUNT
								
								UNION ALL
								
								SELECT NULL, COUNT(*)
								FROM #client
								WHERE DUTY_COUNT <> 0
							) AS t
						ORDER BY DUTY_COUNT FOR XML PATH('')
					) AS NOTE_ALL
				FROM #client a
				WHERE (DUTY_COUNT >= @NUM_BEGIN OR @NUM_BEGIN IS NULL)
					AND (DUTY_COUNT <= @NUM_END OR @NUM_END IS NULL)
			) AS o_O
		ORDER BY ManagerName, ServiceName, ClientFullName
						
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
