USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[HST_TOTAL_REPORT]
	@BEGIN		SMALLDATETIME,
	@END		SMALLDATETIME,
	@TYPE		NVARCHAR(MAX)
AS
BEGIN
	SET NOCOUNT ON;

	SET @END = DATEADD(DAY, 1, @END)
	
	IF OBJECT_ID('tempdb..#cl') IS NOT NULL
		DROP TABLE #cl

	CREATE TABLE #cl(ClientID INT, Service VARCHAR(250), Manager VARCHAR(150), HST_COUNT INT, USR_COUNT INT)
	
	INSERT INTO #cl(ClientID, Service, Manager, HST_COUNT, USR_COUNT)	
			SELECT 
				a.ClientID, ServiceName, ManagerName, 
				(
					SELECT COUNT(DISTINCT SearchGet)
					FROM 
						dbo.ClientSearchTable z
					WHERE z.ClientID = a.ClientID
						AND SearchGetDay >= @BEGIN 
						AND SearchGetDay < @END
				) AS HST_COUNT,
				(
					SELECT COUNT(*)
					FROM 
						USR.USRData z
						INNER JOIN USR.USRFile y ON UF_ID_COMPLECT = z.UD_ID
					WHERE UD_ACTIVE = 1
						AND UF_ACTIVE = 1
						AND (UF_PATH = 0 OR UF_PATH = 3)
						AND	UF_DATE BETWEEN @BEGIN AND @END
						AND z.UD_ID_CLIENT = a.CLientID
				) AS USR_COUNT
			FROM 
				dbo.ClientView a WITH(NOEXPAND)
				INNER JOIN dbo.ClientTable b ON a.ClientID = b.ClientID
				INNER JOIN dbo.TableIDFromXML(@TYPE) c ON ID = ClientContractTypeID
			WHERE b.StatusID = 2						

		SELECT 
			Service, Manager, CL_COUNT, HST_COUNT, CL_KORR_COUNT, HST_KORR_COUNT,
			ROUND(100 * CONVERT(FLOAT, HST_COUNT) / CL_COUNT, 2) AS PRC,
			CASE CL_KORR_COUNT WHEN 0 THEN 0 ELSE ROUND(100 * CONVERT(FLOAT, HST_KORR_COUNT) / CL_KORR_COUNT, 2) END AS KORR_PRC,
			CASE WHEN ROUND(100 * CONVERT(FLOAT, HST_COUNT) / CL_COUNT, 2) < 80 THEN 1 ELSE 0 END AS PRC_BAD,
			CASE CL_KORR_COUNT WHEN 0 THEN 1 ELSE CASE WHEN ROUND(100 * CONVERT(FLOAT, HST_KORR_COUNT) / CL_KORR_COUNT, 2) < 80 THEN 1 ELSE 0 END END AS PRC_KORR_BAD,
			CL_TOTAL, CL_KORR_TOTAL, HST_TOTAL,	HST_KORR_TOTAL,	
			ROUND(100 * CONVERT(FLOAT, HST_TOTAL) / CL_TOTAL, 2) AS TOTAL_PRC,
			CASE CL_KORR_TOTAL WHEN 0 THEN 0 ELSE ROUND(100 * CONVERT(FLOAT, HST_KORR_TOTAL) / CL_KORR_TOTAL, 2) END AS TOTAL_KORR_PRC,
			MAN_CL_TOTAL, MAN_CL_KORR_TOTAL, MAN_HST_TOTAL,	MAN_HST_KORR_TOTAL,	
			ROUND(100 * CONVERT(FLOAT, MAN_HST_TOTAL) / MAN_CL_TOTAL, 2) AS MAN_TOTAL_PRC,
			CASE MAN_CL_KORR_TOTAL WHEN 0 THEN 0 ELSE ROUND(100 * CONVERT(FLOAT, MAN_HST_KORR_TOTAL) / MAN_CL_KORR_TOTAL, 2) END AS MAN_TOTAL_KORR_PRC
		FROM
			(
				SELECT 
					Service, Manager, 
					(
						SELECT COUNT(*)
						FROM #cl b
						WHERE a.Service = b.Service
					) AS CL_COUNT,
					(
						SELECT COUNT(*)
						FROM #cl b
						WHERE a.Service = b.Service
							AND USR_COUNT <> 0
					) AS CL_KORR_COUNT,
					(
						SELECT COUNT(*)
						FROM #cl b
						WHERE a.Service = b.Service
							AND HST_COUNT <> 0
					) AS HST_COUNT,
					(
						SELECT COUNT(*)
						FROM #cl b
						WHERE a.Service = b.Service
							AND HST_COUNT <> 0
							AND USR_COUNT <> 0
					) AS HST_KORR_COUNT,
					(
						SELECT COUNT(*)
						FROM #cl
						WHERE Service IS NOT NULL
					) AS CL_TOTAL,
					(
						SELECT COUNT(*)
						FROM #cl
						WHERE Service IS NOT NULL
							AND USR_COUNT <> 0
					) AS CL_KORR_TOTAL,
					(
						SELECT COUNT(*)
						FROM #cl
						WHERE HST_COUNT <> 0
							AND Service IS NOT NULL
					) AS HST_TOTAL,
					(
						SELECT COUNT(*)
						FROM #cl
						WHERE HST_COUNT <> 0
							AND Service IS NOT NULL
							AND USR_COUNT <> 0
					) AS HST_KORR_TOTAL,
					(
						SELECT COUNT(*)
						FROM #cl b
						WHERE a.Manager = b.Manager
					) AS MAN_CL_TOTAL,
					(
						SELECT COUNT(*)
						FROM #cl b
						WHERE a.Manager = b.Manager
							AND USR_COUNT <> 0
					) AS MAN_CL_KORR_TOTAL,
					(
						SELECT COUNT(*)
						FROM #cl b
						WHERE a.Manager = b.Manager
							AND HST_COUNT <> 0
					) AS MAN_HST_TOTAL,
					(
						SELECT COUNT(*)
						FROM #cl b
						WHERE a.Manager = b.Manager
							AND HST_COUNT <> 0
							AND USR_COUNT <> 0
					) AS MAN_HST_KORR_TOTAL
				FROM
					(
						SELECT DISTINCT Service, Manager
						FROM #cl
						WHERE Service IS NOT NULL
					) AS a
			) AS z

		ORDER BY Manager, Service

	IF OBJECT_ID('tempdb..#cl') IS NOT NULL
		DROP TABLE #cl
END
