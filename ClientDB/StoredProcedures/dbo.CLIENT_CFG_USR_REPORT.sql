USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[CLIENT_CFG_USR_REPORT]
	@BEGIN		SMALLDATETIME,
	@END		SMALLDATETIME,
	@SERVICE	INT,
	@MANAGER	NVARCHAR(MAX),
	@HIDE		BIT,
	@UNGET		BIT = 0,
	@TYPE		NVARCHAR(MAX) = NULL
AS
BEGIN
	SET NOCOUNT ON;

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
			CFG_COUNT		INT
		)

	INSERT INTO #result(ClientID, ClientFullName, ManagerName, ServiceName, USR_COUNT, CFG_COUNT)
		SELECT 
			a.ClientID, a.ClientFullName, ManagerName, ServiceName,
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
				SELECT COUNT(DISTINCT SearchGet)
				FROM 
					dbo.ClientSearchTable z
				WHERE z.ClientID = a.ClientID
					AND SearchGetDay BETWEEN @BEGIN AND @END
			) AS CFG_COUNT
		FROM 
			dbo.ClientView a WITH(NOEXPAND)
			INNER JOIN dbo.ClientTable b ON a.ClientID = b.ClientID
			INNER JOIN dbo.TableIDFromXML(@TYPE) ON ID = ClientContractTypeID
		WHERE ServiceStatusID = 2
			AND (a.ServiceID = @SERVICE OR @SERVICE IS NULL)
			AND (a.ManagerID IN (SELECT ID FROM dbo.TableIDFromXML(@MANAGER)) OR @MANAGER IS NULL)
		ORDER BY ManagerName, ServiceName, ClientFullName
	/*	
	IF @HIDE = 1
		DELETE FROM #result WHERE USR_COUNT = 0
		*/
		
	SELECT 
		ClientID, ClientFullName, ManagerName, ServiceName, USR_COUNT, CFG_COUNT, 
		ClientCount, ACTIVE_COUNT, ERROR_COUNT,
		CASE ACTIVE_COUNT 
			WHEN 0 THEN 0
			ELSE ROUND(100 * CONVERT(FLOAT, ERROR_COUNT) / ACTIVE_COUNT, 2) 
		END AS ERROR_PERCENT,
		ACTIVE_COUNT - ERROR_COUNT AS NORMAL_COUNT,
		100 - CASE ACTIVE_COUNT 
			WHEN 0 THEN 0
			ELSE ROUND(100 * CONVERT(FLOAT, ERROR_COUNT) / ACTIVE_COUNT, 2) 
		END AS NORMAL_PERCENT,
		LAST_UPDATE
	FROM
		(
			SELECT 
				ClientID, ClientFullName, ManagerName, ServiceName, USR_COUNT, CFG_COUNT,
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
						AND USR_COUNT <> 0 AND CFG_COUNT = 0
				) AS ERROR_COUNT,
				dbo.DateOf((
					SELECT MAX(UIU_DATE) 
					FROM USR.USRIBDateView WITH(NOEXPAND)
					WHERE UD_ID_CLIENT = ClientID
				)) AS LAST_UPDATE
			FROM #result a
			WHERE (USR_COUNT <> 0 AND @HIDE = 1 OR @HIDE = 0)
				AND (CFG_COUNT = 0 AND @UNGET = 1 OR @UNGET = 0)
		) AS o_O
	ORDER BY ManagerName, ServiceName, ClientFullName

	IF OBJECT_ID('tempdb..#result') IS NOT NULL
		DROP TABLE #result
END
