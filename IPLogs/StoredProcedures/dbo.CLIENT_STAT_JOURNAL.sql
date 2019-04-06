USE [IPLogs]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[CLIENT_STAT_JOURNAL]
	@BEGIN	SMALLDATETIME,
	@END	SMALLDATETIME,
	@ERROR	BIT,
	@SERVER	INT = NULL
WITH EXECUTE AS OWNER
AS
BEGIN
	SET NOCOUNT ON;

	--SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

	SET @END = DATEADD(DAY, 1, @END)

	SELECT 
		CONVERT(BIT, CASE 
			WHEN e.DISTR IS NULL THEN 0
			ELSE 1
		END) AS BLACK_LIST,
		CASE b.Service
			WHEN 0 THEN 0
			WHEN 1 THEN 1
			WHEN 2 THEN 3
			ELSE NULL
		END AS SERVICE_STATUS,
		b.SystemShortName + ' ' + CONVERT(VARCHAR(20), CSD_DISTR) + 
		CASE CSD_COMP
			WHEN 1 THEN ''
			ELSE '/' + CONVERT(VARCHAR(20), CSD_COMP)
		END AS Complect,
		--ISNULL(c.Comment, d.COMMENT) AS Comment,
		b.Comment AS Comment,
		ISNULL(CSD_START, CSD_END) AS CSD_DATE,
		ISNULL(dbo.TimeSecToStr(DATEDIFF(SECOND, CSD_START, CSD_END)), '') AS TIME_LEN,
		ISNULL(dbo.FileSizeToStr(CSD_ANS_SIZE + CSD_CACHE_SIZE), '') AS DOWNLOAD_SIZE,
		CONVERT(VARCHAR(20), CSD_CODE_CLIENT) + ' (' +
			ISNULL(( 
				SELECT TOP 1 RC_TEXT
				FROM dbo.ReturnCode
				WHERE RC_NUM = CSD_CODE_CLIENT 
					AND RC_TYPE = 'CLIENT'
				ORDER BY RC_ID
			), 'неизвестный код') + ')' AS CODE_CLIENT,
		CONVERT(VARCHAR(20), CSD_CODE_SERVER) + ' (' +
			ISNULL(( 
				SELECT TOP 1 RC_TEXT
				FROM dbo.ReturnCode
				WHERE RC_NUM = CSD_CODE_SERVER 
					AND RC_TYPE = 'SERVER'
				ORDER BY RC_ID
			), 'неизвестный код') + ')' AS CODE_SERVER,
		CASE
			WHEN EXISTS
				(
					SELECT *
					FROM dbo.ReturnCode
					WHERE RC_NUM = CSD_CODE_SERVER
						AND RC_TYPE = 'SERVER'
						AND RC_ERROR = 1
				
					UNION ALL

					SELECT *
					FROM dbo.ReturnCode
					WHERE RC_NUM = CSD_CODE_CLIENT
						AND RC_TYPE = 'CLIENT'
						AND RC_ERROR = 1
				) THEN 2
			WHEN EXISTS
				(
					SELECT *
					FROM dbo.ReturnCode
					WHERE RC_NUM = CSD_CODE_SERVER
						AND RC_TYPE = 'SERVER'
						AND RC_WARNING = 1
				
					UNION ALL

					SELECT *
					FROM dbo.ReturnCode
					WHERE RC_NUM = CSD_CODE_CLIENT
						AND RC_TYPE = 'CLIENT'
						AND RC_WARNING = 1
				) THEN 8
			ELSE 0
		END AS STAT,
		CASE
			WHEN EXISTS
				(
					SELECT *
					FROM dbo.ClientStatDetail b
					WHERE a.CSD_SYS = b.CSD_SYS
						AND a.CSD_DISTR = b.CSD_DISTR
						AND a.CSD_COMP = b.CSD_COMP
						AND a.CSD_ID <> b.CSD_ID
						AND ISNULL(a.CSD_START, a.CSD_END) > ISNULL(b.CSD_START, b.CSD_END)
				) THEN 0
			ELSE 1
		END AS CSD_NEW,
		SRV_NAME
	FROM
		dbo.ClientStatDetail a
		INNER JOIN dbo.ClientStat ON CS_ID = CSD_ID_CS
		INNER JOIN dbo.Files ON CS_ID_FILE = FL_ID
		INNER JOIN dbo.Servers ON FL_ID_SERVER = SRV_ID
		/*OUTER APPLY
			(
				SELECT TOP 1 d.SystemShortName, d.SystemID, Comment, Service
				FROM 
					[PC275-SQL\ALPHA].ClientDB.dbo.RegNodeTable c
					INNER JOIN [PC275-SQL\ALPHA].ClientDB.dbo.SystemTable b ON c.SystemName = b.SystemBaseName
					INNER JOIN [PC275-SQL\ALPHA].ClientDB.dbo.SystemTable d ON d.HostID = b.HostID
				WHERE d.SystemNumber = a.CSD_SYS 
					AND c.DistrNumber = a.CSD_DISTR 
					AND c.CompNumber = a.CSD_COMP
					AND b.SystemRic = 20 AND d.SystemRic = 20
			) AS b*/
		LEFT OUTER JOIN
			(
				SELECT --TOP 1 
					DISTINCT
					d.SystemShortName, d.SystemID, Comment, Service, d.SystemNumber, c.DistrNumber, c.CompNumber--,
					--ROW_NUMBER() OVER(PARTITION BY b.HostID, DistrNumber, CompNumber ORDER BY Comment) AS RN
				FROM 
					[PC275-SQL\ALPHA].ClientDB.dbo.RegNodeTable c
					INNER JOIN [PC275-SQL\ALPHA].ClientDB.dbo.SystemTable b ON c.SystemName = b.SystemBaseName
					INNER JOIN [PC275-SQL\ALPHA].ClientDB.dbo.SystemTable d ON d.HostID = b.HostID
				WHERE /*d.SystemNumber = a.CSD_SYS 
					AND c.DistrNumber = a.CSD_DISTR 
					AND c.CompNumber = a.CSD_COMP
					AND */b.SystemRic = 20 AND d.SystemRic = 20
			) AS b ON b.SystemNumber = a.CSD_SYS 
					AND b.DistrNumber = a.CSD_DISTR 
					AND b.CompNumber = a.CSD_COMP
					--AND b.RN = 1
		LEFT OUTER JOIN 
			(
				SELECT DISTINCT ID_SYS, DISTR, COMP
				FROM [PC275-SQL\ALPHA].ClientDB.dbo.BLACK_LIST_REG
				WHERE DATE_DELETE IS NULL 
			) AS e ON e.ID_SYS = b.SystemID
					AND e.DISTR = a.CSD_DISTR
					AND e.COMP = a.CSD_COMP
	WHERE (ISNULL(CSD_START, CSD_END) >= @BEGIN OR @BEGIN IS NULL)
		AND (ISNULL(CSD_START, CSD_END) < @END OR @END IS NULL)
		AND (SRV_ID = @SERVER OR @SERVER IS NULL)
		AND
			((
				(
					CSD_CODE_CLIENT IN
						(
							SELECT RC_NUM
							FROM dbo.ReturnCode
							WHERE RC_ERROR = 1
								AND RC_TYPE = 'CLIENT'
						)
				) OR @ERROR = 0
			)
		OR
			(
				(
					CSD_CODE_SERVER IN
						(
							SELECT RC_NUM
							FROM dbo.ReturnCode
							WHERE RC_ERROR = 1
								AND RC_TYPE = 'SERVER'
						)
				) OR @ERROR = 0
			))
	ORDER BY ISNULL(CSD_START, CSD_END) DESC, Comment
END
