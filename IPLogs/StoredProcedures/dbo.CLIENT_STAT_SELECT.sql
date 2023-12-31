USE [IPLogs]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[CLIENT_STAT_SELECT]
	@CLIENT			INT = NULL,
	@CLIENT_TYPE	NVARCHAR(20) = NULL,
	@BEGIN			DATETIME = NULL,
	@END			DATETIME = NULL,
	@TRAF			VARCHAR(100) = NULL OUTPUT
WITH EXECUTE AS OWNER
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

	    IF OBJECT_ID('tempdb..#stat') IS NOT NULL
		    DROP TABLE #stat

	    CREATE TABLE #stat
		    (
			    ID BIGINT IDENTITY(1, 1) PRIMARY KEY NONCLUSTERED,
			    MASTER_ID BIGINT,
			    SYS_ID BIGINT,
			    SYS_NAME NVARCHAR(50),
			    NODE_NAME NVARCHAR(100),
			    NODE_VALUE NVARCHAR(500),
			    NODE_LINK NVARCHAR(256),
			    SRV	NVARCHAR(128),
			    STAT BIGINT DEFAULT 0
		    )

	    DECLARE @SQL VARCHAR(MAX)
	    SET @SQL = 'CREATE CLUSTERED INDEX [IX_' + CONVERT(VARCHAR(50), NEWID()) + '] ON #stat (SYS_ID, SYS_NAME)'
	    EXEC (@SQL)

	    IF @CLIENT IS NULL AND (@BEGIN IS NULL AND @END IS NULL)
	    BEGIN
		    SELECT ID, MASTER_ID, NODE_NAME, NODE_VALUE, NODE_LINK, SRV, STAT
		    FROM #stat
		    ORDER BY ID
    
		    RETURN
	    END

	    IF OBJECT_ID('tempdb..#client') IS NOT NULL
		    DROP TABLE #client

	    CREATE TABLE #client
		    (
			    CSD_ID BIGINT PRIMARY KEY,
			    CSD_SYS SMALLINT,
			    CSD_DISTR INT,
			    CSD_COMP SMALLINT,
			    CSD_IP NVARCHAR(50),
			    CSD_SESSION NVARCHAR(50),
			    CSD_START DATETIME,
			    CSD_QST_TIME SMALLINT,
			    CSD_QST_SIZE BIGINT,
			    CSD_ANS_TIME SMALLINT,
			    CSD_ANS_SIZE BIGINT,
			    CSD_CACHE_TIME SMALLINT,
			    CSD_CACHE_SIZE BIGINT,
			    CSD_DOWNLOAD_TIME INT,
			    CSD_UPDATE_TIME INT,
			    CSD_REPORT_TIME SMALLINT,
			    CSD_REPORT_SIZE BIGINT,
			    CSD_END DATETIME,
			    CSD_REDOWNLOAD BIT,
			    CSD_LOG_PATH NVARCHAR(256),
			    CSD_LOG_FILE NVARCHAR(256),
			    CSD_LOG_RESULT NVARCHAR(256),
			    CSD_LOG_LETTER NVARCHAR(256),
			    CSD_USR NVARCHAR(256),
			    CSD_CODE_CLIENT INT,
			    CSD_CODE_SERVER INT,
			    CSD_IP_MODE NVARCHAR(64),
			    CSD_ID_SERVER	INT,
			    CSD_RES_VERSION	NVARCHAR(64),
			    CSD_DOWNLOAD_SPEED	BIGINT,
			    CSD_STT_SEND BIT,
			    CSD_STT_RESULT BIT,
			    CSD_INET_EXT BIT,
			    CSD_PROXY_METOD	NVARCHAR(128),
			    CSD_PROXY_INTERFACE	NVARCHAR(128)
		    )
    
	    INSERT INTO #client
		    (
			    CSD_ID,
			    CSD_SYS, CSD_DISTR, CSD_COMP,
			    CSD_IP, CSD_SESSION,
			    CSD_START,
			    CSD_QST_TIME, CSD_QST_SIZE, CSD_ANS_TIME, CSD_ANS_SIZE, CSD_CACHE_TIME, CSD_CACHE_SIZE,
			    CSD_DOWNLOAD_TIME, CSD_UPDATE_TIME, CSD_REPORT_TIME, CSD_REPORT_SIZE,
			    CSD_END, CSD_REDOWNLOAD,
			    CSD_LOG_PATH, CSD_LOG_FILE, CSD_LOG_RESULT, CSD_LOG_LETTER,
			    CSD_USR,
			    CSD_CODE_CLIENT, CSD_CODE_SERVER, CSD_IP_MODE,
			    CSD_ID_SERVER, CSD_RES_VERSION, CSD_DOWNLOAD_SPEED,
			    CSD_STT_SEND, CSD_STT_RESULT, CSD_INET_EXT, CSD_PROXY_METOD, CSD_PROXY_INTERFACE
		    )
		    SELECT
			    CSD_ID,
			    CSD_SYS, CSD_DISTR, CSD_COMP,
			    CSD_IP, CSD_SESSION,
			    ISNULL(CSD_START, CSD_END),
			    CSD_QST_TIME, CSD_QST_SIZE, CSD_ANS_TIME, CSD_ANS_SIZE, CSD_CACHE_TIME, CSD_CACHE_SIZE,
			    CSD_DOWNLOAD_TIME, CSD_UPDATE_TIME, CSD_REPORT_TIME, CSD_REPORT_SIZE,
			    ISNULL(CSD_END, CSD_START), CSD_REDOWNLOAD,
			    CSD_LOG_PATH, CSD_LOG_FILE, CSD_LOG_RESULT, CSD_LOG_LETTER,
			    CSD_USR,
			    CSD_CODE_CLIENT, CSD_CODE_SERVER, CSD_IP_MODE,
			    (
				    SELECT FL_ID_SERVER
				    FROM
					    dbo.Files
					    INNER JOIN dbo.ClientStat ON CS_ID_FILE = FL_ID
				    WHERE CS_ID = CSD_ID_CS
			    ), CSD_RES_VERSION, CSD_DOWNLOAD_SPEED,
			    CSD_STT_SEND, CSD_STT_RESULT, CSD_INET_EXT, CSD_PROXY_METOD, CSD_PROXY_INTERFACE
		    FROM
			    dbo.ClientStatDetail a
		    WHERE @CLIENT_TYPE = 'OIS' AND EXISTS
			    (
				    SELECT *
				    FROM
					    [PC275-SQL\ALPHA].ClientDB.dbo.ClientDistrView b WITH(NOEXPAND) INNER JOIN
					    [PC275-SQL\ALPHA].ClientDB.dbo.SystemTable c ON b.SystemID = c.SystemID
				    WHERE ID_CLIENT = @CLIENT
					    AND SystemNumber = CSD_SYS
					    AND CSD_DISTR = DISTR
					    AND CSD_COMP = COMP
			    )
			    AND (ISNULL(CSD_START, CSD_END) >= @BEGIN OR @BEGIN IS NULL)
			    AND (ISNULL(CSD_START, CSD_END) <= @END OR @END IS NULL)

		    UNION ALL

		    SELECT
			    CSD_ID,
			    CSD_SYS, CSD_DISTR, CSD_COMP,
			    CSD_IP, CSD_SESSION,
			    ISNULL(CSD_START, CSD_END),
			    CSD_QST_TIME, CSD_QST_SIZE, CSD_ANS_TIME, CSD_ANS_SIZE, CSD_CACHE_TIME, CSD_CACHE_SIZE,
			    CSD_DOWNLOAD_TIME, CSD_UPDATE_TIME, CSD_REPORT_TIME, CSD_REPORT_SIZE,
			    ISNULL(CSD_END, CSD_START), CSD_REDOWNLOAD,
			    CSD_LOG_PATH, CSD_LOG_FILE, CSD_LOG_RESULT, CSD_LOG_LETTER,
			    CSD_USR,
			    CSD_CODE_CLIENT, CSD_CODE_SERVER, CSD_IP_MODE,
			    (
				    SELECT FL_ID_SERVER
				    FROM
					    dbo.Files
					    INNER JOIN dbo.ClientStat ON CS_ID_FILE = FL_ID
				    WHERE CS_ID = CSD_ID_CS
			    ), CSD_RES_VERSION, CSD_DOWNLOAD_SPEED,
			    CSD_STT_SEND, CSD_STT_RESULT, CSD_INET_EXT, CSD_PROXY_METOD, CSD_PROXY_INTERFACE
		    FROM
			    dbo.ClientStatDetail a
		    WHERE @CLIENT_TYPE = 'DBF' AND EXISTS
			    (
				    SELECT *
				    FROM
					    [PC275-SQL\DELTA].DBF.dbo.TODistrTable b INNER JOIN
					    [PC275-SQL\DELTA].DBF.dbo.DistrView c ON c.DIS_ID = b.TD_ID_DISTR INNER JOIN
					    [PC275-SQL\ALPHA].ClientDB.dbo.SystemTable d ON SystemBaseName = SYS_REG_NAME
				    WHERE TD_ID_TO = @CLIENT
					    AND CSD_SYS = SystemNumber
					    AND CSD_DISTR = DIS_NUM
					    AND CSD_COMP = DIS_COMP_NUM
			    )
			    AND (ISNULL(CSD_START, CSD_END) >= @BEGIN OR @BEGIN IS NULL)
			    AND (ISNULL(CSD_START, CSD_END) <= @END OR @END IS NULL)

		    UNION ALL

		    SELECT
			    CSD_ID,
			    CSD_SYS, CSD_DISTR, CSD_COMP,
			    CSD_IP, CSD_SESSION,
			    ISNULL(CSD_START, CSD_END),
			    CSD_QST_TIME, CSD_QST_SIZE, CSD_ANS_TIME, CSD_ANS_SIZE, CSD_CACHE_TIME, CSD_CACHE_SIZE,
			    CSD_DOWNLOAD_TIME, CSD_UPDATE_TIME, CSD_REPORT_TIME, CSD_REPORT_SIZE,
			    ISNULL(CSD_END, CSD_START), CSD_REDOWNLOAD,
			    CSD_LOG_PATH, CSD_LOG_FILE, CSD_LOG_RESULT, CSD_LOG_LETTER,
			    CSD_USR,
			    CSD_CODE_CLIENT, CSD_CODE_SERVER, CSD_IP_MODE,
			    (
				    SELECT FL_ID_SERVER
				    FROM
					    dbo.Files
					    INNER JOIN dbo.ClientStat ON CS_ID_FILE = FL_ID
				    WHERE CS_ID = CSD_ID_CS
			    ), CSD_RES_VERSION, CSD_DOWNLOAD_SPEED,
			    CSD_STT_SEND, CSD_STT_RESULT, CSD_INET_EXT, CSD_PROXY_METOD, CSD_PROXY_INTERFACE
		    FROM
			    dbo.ClientStatDetail a
		    WHERE @CLIENT_TYPE = 'REG' AND @CLIENT <> -1 AND EXISTS
			    (
				    SELECT *
				    FROM
					    [PC275-SQL\ALPHA].ClientDB.dbo.RegNodeTable b INNER JOIN
					    [PC275-SQL\ALPHA].ClientDB.dbo.SystemTable c ON b.SystemName = c.SystemBaseName
				    WHERE ID = @CLIENT
					    AND SystemNumber = CSD_SYS
					    AND CSD_DISTR = DistrNumber
					    AND CSD_COMP = CompNumber
			    )
			    AND (ISNULL(CSD_START, CSD_END) >= @BEGIN OR @BEGIN IS NULL)
			    AND (ISNULL(CSD_START, CSD_END) <= @END OR @END IS NULL)

		    UNION ALL

		    SELECT
			    CSD_ID,
			    CSD_SYS, CSD_DISTR, CSD_COMP,
			    CSD_IP, CSD_SESSION,
			    ISNULL(CSD_START, CSD_END),
			    CSD_QST_TIME, CSD_QST_SIZE, CSD_ANS_TIME, CSD_ANS_SIZE, CSD_CACHE_TIME, CSD_CACHE_SIZE,
			    CSD_DOWNLOAD_TIME, CSD_UPDATE_TIME, CSD_REPORT_TIME, CSD_REPORT_SIZE,
			    ISNULL(CSD_END, CSD_START), CSD_REDOWNLOAD,
			    CSD_LOG_PATH, CSD_LOG_FILE, CSD_LOG_RESULT, CSD_LOG_LETTER,
			    CSD_USR,
			    CSD_CODE_CLIENT, CSD_CODE_SERVER, CSD_IP_MODE,
			    (
				    SELECT FL_ID_SERVER
				    FROM
					    dbo.Files
					    INNER JOIN dbo.ClientStat ON CS_ID_FILE = FL_ID
				    WHERE CS_ID = CSD_ID_CS
			    ), CSD_RES_VERSION, CSD_DOWNLOAD_SPEED,
			    CSD_STT_SEND, CSD_STT_RESULT, CSD_INET_EXT, CSD_PROXY_METOD, CSD_PROXY_INTERFACE
		    FROM
			    dbo.ClientStatDetail a
		    WHERE @CLIENT_TYPE = 'REG' AND @CLIENT = -1
			    AND CSD_DISTR = 490 AND CSD_COMP IN (1, 7)
			    AND (ISNULL(CSD_START, CSD_END) >= @BEGIN OR @BEGIN IS NULL)
			    AND (ISNULL(CSD_START, CSD_END) <= @END OR @END IS NULL)
    
    
	    SELECT @TRAF = dbo.FileSizeToStr(SZ)
	    FROM
		    (
			    SELECT SUM(CSD_ANS_SIZE + CSD_CACHE_SIZE) AS SZ
			    FROM #client
		    ) AS o_O

	    --SET @SQL = 'CREATE CLUSTERED INDEX [IX_' + CONVERT(VARCHAR(50), NEWID()) + '] ON #client (CSD_ID)'
	    --EXEC (@SQL)
    
	    DECLARE @srv NVARCHAR(50)
	    DECLARE @clt NVARCHAR(50)
	    DECLARE @rep NVARCHAR(50)
	    DECLARE @usr NVARCHAR(50)
	    DECLARE @cpl NVARCHAR(50)

	    SET @srv = 'SERVER'
	    SET @clt = 'CLIENT'
	    SET @rep = 'REPORT'
	    SET @usr = 'USR'
	    SET @cpl = 'COMPLECT'

	    DELETE FROM #client
	    WHERE CSD_ID NOT IN
		    (
			    SELECT TOP 100 CSD_ID
			    FROM #client
			    ORDER BY CSD_START DESC, CSD_ID DESC
		    )

	    INSERT INTO #stat
		    (
			    MASTER_ID, SYS_ID, SYS_NAME, NODE_NAME, NODE_VALUE, SRV, STAT
		    )
		    SELECT NULL, CSD_ID, @cpl,
			    (
				    SELECT TOP 1
					    SystemShortName + ' ' +
					    CONVERT(VARCHAR(20), CSD_DISTR) +
					    CASE CSD_COMP
						    WHEN 1 THEN ''
						    ELSE '/' + CONVERT(VARCHAR(10), CSD_COMP)
					    END
				    FROM [PC275-SQL\ALPHA].ClientDB.dbo.SystemTable
				    WHERE SystemNumber = CSD_SYS
				    ORDER BY SystemOrder
			    ), CONVERT(VARCHAR(20), CSD_START, 104) + ' ' + CONVERT(VARCHAR(20), CSD_START, 114),
			    (
				    SELECT SRV_NAME
				    FROM dbo.Servers
				    WHERE SRV_ID = CSD_ID_SERVER
			    ),
			    CASE
				    WHEN CSD_CODE_SERVER <> 0 OR (CSD_CODE_CLIENT <> 0 AND CSD_CODE_CLIENT <> 70) OR CSD_LOG_LETTER <> '-' THEN 2
				    WHEN CSD_CODE_SERVER = 0 AND (CSD_CODE_CLIENT = 0 OR CSD_CODE_CLIENT = 70) AND CSD_LOG_LETTER = '-' AND CSD_USR = '-' THEN 4
				    ELSE 0
			    END
		    FROM #client
		    ORDER BY CSD_START DESC
    
	    INSERT INTO #stat
		    (
			    MASTER_ID, SYS_ID, SYS_NAME, NODE_NAME, NODE_VALUE, STAT
		    )
		    SELECT
			    (
				    SELECT ID
				    FROM #stat
				    WHERE SYS_ID = CSD_ID AND SYS_NAME = @cpl
			    ), CSD_ID, @srv, '���������� �������', '', 3
		    FROM #client
	    INSERT INTO #stat
		    (
			    MASTER_ID, SYS_ID, SYS_NAME, NODE_NAME, NODE_VALUE
		    )
		    SELECT
			    (
				    SELECT ID
				    FROM #stat
				    WHERE SYS_ID = CSD_ID AND SYS_NAME = @srv
			    ), CSD_ID, NULL, 'ID ������',  CSD_SESSION
		    FROM #client

	    INSERT INTO #stat
		    (
			    MASTER_ID, SYS_ID, SYS_NAME, NODE_NAME, NODE_VALUE
		    )
		    SELECT
			    (
				    SELECT ID
				    FROM #stat
				    WHERE SYS_ID = CSD_ID AND SYS_NAME = @srv
			    ), CSD_ID, NULL, '����� ��������� ������ � ������� �������� (���)',  dbo.TimeSecToStr(CSD_QST_TIME)
		    FROM #client
    
	    INSERT INTO #stat
		    (
			    MASTER_ID, SYS_ID, SYS_NAME, NODE_NAME, NODE_VALUE
		    )
		    SELECT
			    (
				    SELECT ID
				    FROM #stat
				    WHERE SYS_ID = CSD_ID AND SYS_NAME = @srv
			    ), CSD_ID, NULL, '������ ������ � ������� ��������',  dbo.FileSizeToStr(CSD_QST_SIZE)
		    FROM #client

	    INSERT INTO #stat
		    (
			    MASTER_ID, SYS_ID, SYS_NAME, NODE_NAME, NODE_VALUE
		    )
		    SELECT
			    (
				    SELECT ID
				    FROM #stat
				    WHERE SYS_ID = CSD_ID AND SYS_NAME = @srv
			    ), CSD_ID, NULL, '����� ������������ ����� �������',  dbo.TimeSecToStr(CSD_ANS_TIME)
		    FROM #client

	    INSERT INTO #stat
		    (
			    MASTER_ID, SYS_ID, SYS_NAME, NODE_NAME, NODE_VALUE
		    )
		    SELECT
			    (
				    SELECT ID
				    FROM #stat
				    WHERE SYS_ID = CSD_ID AND SYS_NAME = @srv
			    ), CSD_ID, NULL, '������ ������ � ������� �������',  dbo.FileSizeToStr(CSD_ANS_SIZE)
		    FROM #client

	    INSERT INTO #stat
		    (
			    MASTER_ID, SYS_ID, SYS_NAME, NODE_NAME, NODE_VALUE
		    )
		    SELECT
			    (
				    SELECT ID
				    FROM #stat
				    WHERE SYS_ID = CSD_ID AND SYS_NAME = @srv
			    ), CSD_ID, NULL, '������ ������ � ������� � ����',  dbo.FileSizeToStr(CSD_CACHE_SIZE)
		    FROM #client
    

	    INSERT INTO #stat
		    (
			    MASTER_ID, SYS_ID, SYS_NAME, NODE_NAME, NODE_VALUE, STAT
		    )
		    SELECT
			    (
				    SELECT ID
				    FROM #stat
				    WHERE SYS_ID = CSD_ID AND SYS_NAME = @cpl
			    ), CSD_ID, @clt, '���������� �������',  '', 3
		    FROM #client

	    INSERT INTO #stat
		    (
			    MASTER_ID, SYS_ID, SYS_NAME, NODE_NAME, NODE_VALUE
		    )
		    SELECT
			    (
				    SELECT ID
				    FROM #stat
				    WHERE SYS_ID = CSD_ID AND SYS_NAME = @clt
			    ), CSD_ID, NULL, 'IP-�����',  CSD_IP
		    FROM #client
    
	    INSERT INTO #stat
		    (
			    MASTER_ID, SYS_ID, SYS_NAME, NODE_NAME, NODE_VALUE
		    )
		    SELECT
			    (
				    SELECT ID
				    FROM #stat
				    WHERE SYS_ID = CSD_ID AND SYS_NAME = @clt
			    ), CSD_ID, NULL, '����� ����������',  dbo.TimeSecToStr(CSD_DOWNLOAD_TIME)
		    FROM #client
    
	    INSERT INTO #stat
		    (
			    MASTER_ID, SYS_ID, SYS_NAME, NODE_NAME, NODE_VALUE
		    )
		    SELECT
			    (
				    SELECT ID
				    FROM #stat
				    WHERE SYS_ID = CSD_ID AND SYS_NAME = @clt
			    ), CSD_ID, NULL, '�������� ����������',  dbo.FileSizeToStr(CSD_DOWNLOAD_SPEED * 1024) + '/�'
		    FROM #client

	    INSERT INTO #stat
		    (
			    MASTER_ID, SYS_ID, SYS_NAME, NODE_NAME, NODE_VALUE
		    )
		    SELECT
			    (
				    SELECT ID
				    FROM #stat
				    WHERE SYS_ID = CSD_ID AND SYS_NAME = @clt
			    ), CSD_ID, NULL, '����� ����������',  dbo.TimeSecToStr(CSD_UPDATE_TIME)
		    FROM #client

	    INSERT INTO #stat
		    (
			    MASTER_ID, SYS_ID, SYS_NAME, NODE_NAME, NODE_VALUE
		    )
		    SELECT
			    (
				    SELECT ID
				    FROM #stat
				    WHERE SYS_ID = CSD_ID AND SYS_NAME = @clt
			    ), CSD_ID, NULL, '����� ��������� ������',  CONVERT(VARCHAR(20), CSD_END, 104) + ' ' + CONVERT(VARCHAR(20), CSD_END, 114)
		    FROM #client

	    INSERT INTO #stat
		    (
			    MASTER_ID, SYS_ID, SYS_NAME, NODE_NAME, NODE_VALUE
		    )
		    SELECT
			    (
				    SELECT ID
				    FROM #stat
				    WHERE SYS_ID = CSD_ID AND SYS_NAME = @clt
			    ), CSD_ID, NULL, '�������',  CASE CSD_REDOWNLOAD WHEN 1 THEN '��' ELSE '���' END
		    FROM #client

	    INSERT INTO #stat
		    (
			    MASTER_ID, SYS_ID, SYS_NAME, NODE_NAME, NODE_VALUE
		    )
		    SELECT
			    (
				    SELECT ID
				    FROM #stat
				    WHERE SYS_ID = CSD_ID AND SYS_NAME = @clt
			    ), CSD_ID, NULL, '����� ������� ����������',  CSD_IP_MODE
		    FROM #client
    
	    INSERT INTO #stat
		    (
			    MASTER_ID, SYS_ID, SYS_NAME, NODE_NAME, NODE_VALUE
		    )
		    SELECT
			    (
				    SELECT ID
				    FROM #stat
				    WHERE SYS_ID = CSD_ID AND SYS_NAME = @clt
			    ), CSD_ID, NULL, '������ ���.������',  CSD_RES_VERSION
		    FROM #client
    
	    INSERT INTO #stat
		    (
			    MASTER_ID, SYS_ID, SYS_NAME, NODE_NAME, NODE_VALUE
		    )
		    SELECT
			    (
				    SELECT ID
				    FROM #stat
				    WHERE SYS_ID = CSD_ID AND SYS_NAME = @clt
			    ), CSD_ID, NULL, '�������� STT',  CASE CSD_STT_SEND WHEN 0 THEN '����' WHEN 1 THEN '���' ELSE '�� ����������' END
		    FROM #client
    
	    INSERT INTO #stat
		    (
			    MASTER_ID, SYS_ID, SYS_NAME, NODE_NAME, NODE_VALUE
		    )
		    SELECT
			    (
				    SELECT ID
				    FROM #stat
				    WHERE SYS_ID = CSD_ID AND SYS_NAME = @clt
			    ), CSD_ID, NULL, '��������� STT',  CASE CSD_STT_RESULT WHEN 0 THEN '����' WHEN 1 THEN '���' ELSE '�� ����������' END
		    FROM #client
    
	    INSERT INTO #stat
		    (
			    MASTER_ID, SYS_ID, SYS_NAME, NODE_NAME, NODE_VALUE
		    )
		    SELECT
			    (
				    SELECT ID
				    FROM #stat
				    WHERE SYS_ID = CSD_ID AND SYS_NAME = @clt
			    ), CSD_ID, NULL, '������������� /INET_EXT',  CASE CSD_INET_EXT WHEN 0 THEN '����' WHEN 1 THEN '���' ELSE '�� ����������' END
		    FROM #client
    
	    INSERT INTO #stat
		    (
			    MASTER_ID, SYS_ID, SYS_NAME, NODE_NAME, NODE_VALUE
		    )
		    SELECT
			    (
				    SELECT ID
				    FROM #stat
				    WHERE SYS_ID = CSD_ID AND SYS_NAME = @clt
			    ), CSD_ID, NULL, '����� ����������� ���������� ������',  CSD_PROXY_METOD
		    FROM #client
    
	    INSERT INTO #stat
		    (
			    MASTER_ID, SYS_ID, SYS_NAME, NODE_NAME, NODE_VALUE
		    )
		    SELECT
			    (
				    SELECT ID
				    FROM #stat
				    WHERE SYS_ID = CSD_ID AND SYS_NAME = @clt
			    ), CSD_ID, NULL, '��������� ������ � ����������',  CSD_PROXY_INTERFACE
		    FROM #client
    
	    INSERT INTO #stat
		    (
			    MASTER_ID, SYS_ID, SYS_NAME, NODE_NAME, NODE_VALUE, STAT
		    )
		    SELECT
			    (
				    SELECT ID
				    FROM #stat
				    WHERE SYS_ID = CSD_ID AND SYS_NAME = @cpl
			    ), CSD_ID, @rep, '���������',  '',
			    CASE
				    WHEN CSD_CODE_SERVER <> 0 OR (CSD_CODE_CLIENT <> 0 AND CSD_CODE_CLIENT <> 70) OR CSD_LOG_LETTER <> '-' THEN 2
				    WHEN CSD_CODE_SERVER = 0 AND CSD_CODE_CLIENT = 0 AND CSD_LOG_LETTER = '-' AND CSD_USR = '-' THEN 4
				    ELSE 0
			    END
		    FROM #client

	    INSERT INTO #stat
		    (
			    MASTER_ID, SYS_ID, SYS_NAME, NODE_NAME, NODE_VALUE
		    )
		    SELECT
			    (
				    SELECT ID
				    FROM #stat
				    WHERE SYS_ID = CSD_ID AND SYS_NAME = @rep
			    ), CSD_ID, NULL, '����� �������� ������',  dbo.TimeSecToStr(CSD_REPORT_TIME)
		    FROM #client

	    INSERT INTO #stat
		    (
			    MASTER_ID, SYS_ID, SYS_NAME, NODE_NAME, NODE_VALUE
		    )
		    SELECT
			    (
				    SELECT ID
				    FROM #stat
				    WHERE SYS_ID = CSD_ID AND SYS_NAME = @rep
			    ), CSD_ID, NULL, '������ ����� ������',  dbo.FileSizeToStr(CSD_REPORT_SIZE)
		    FROM #client

	    INSERT INTO #stat
		    (
			    MASTER_ID, SYS_ID, SYS_NAME, NODE_NAME, NODE_VALUE, NODE_LINK, STAT
		    )
		    SELECT
			    (
				    SELECT ID
				    FROM #stat
				    WHERE SYS_ID = CSD_ID AND SYS_NAME = @rep
			    ), CSD_ID, NULL, '���-����', '�������',
			    CASE CSD_LOG_FILE
				    WHEN '-' THEN '���'
				    ELSE
					    (
						    SELECT SRV_PATH
						    FROM dbo.Servers
						    WHERE SRV_ID = CSD_ID_SERVER
					    ) + CSD_LOG_PATH + '\' + CSD_LOG_FILE
			    END, CASE CSD_LOG_FILE WHEN '-' THEN 0 ELSE 6 END
    
		    FROM #client

	    INSERT INTO #stat
		    (
			    MASTER_ID, SYS_ID, SYS_NAME, NODE_NAME, NODE_VALUE, NODE_LINK, STAT
		    )
		    SELECT
			    (
				    SELECT ID
				    FROM #stat
				    WHERE SYS_ID = CSD_ID AND SYS_NAME = @rep
			    ), CSD_ID, NULL, '��� ���� ����������', '�������',
			    CASE CSD_LOG_RESULT
				    WHEN '-' THEN '���'
				    ELSE (
						    SELECT SRV_PATH
						    FROM dbo.Servers
						    WHERE SRV_ID = CSD_ID_SERVER
					    ) + CSD_LOG_PATH + '\' + CSD_LOG_RESULT
			    END, CASE CSD_LOG_RESULT WHEN '-' THEN 0 ELSE 6 END
		    FROM #client

	    INSERT INTO #stat
		    (
			    MASTER_ID, SYS_ID, SYS_NAME, NODE_NAME, NODE_VALUE, NODE_LINK, STAT
		    )
		    SELECT
			    (
				    SELECT ID
				    FROM #stat
				    WHERE SYS_ID = CSD_ID AND SYS_NAME = @rep
			    ), CSD_ID, NULL, '����� (������)', '�������',
			    CASE CSD_LOG_LETTER
				    WHEN '-' THEN '���'
				    ELSE (
						    SELECT SRV_PATH
						    FROM dbo.Servers
						    WHERE SRV_ID = CSD_ID_SERVER
					    ) + CSD_LOG_PATH + '\' + CSD_LOG_LETTER
			    END, CASE CSD_LOG_LETTER WHEN '-' THEN 0 ELSE 6 END
		    FROM #client

	    INSERT INTO #stat
		    (
			    MASTER_ID, SYS_ID, SYS_NAME, NODE_NAME, NODE_VALUE
		    )
		    SELECT
			    (
				    SELECT ID
				    FROM #stat
				    WHERE SYS_ID = CSD_ID AND SYS_NAME = @rep
			    ), CSD_ID, NULL, '��� �������',
			    CONVERT(VARCHAR(20), CSD_CODE_CLIENT) + ' (' +
			    ISNULL((
				    SELECT TOP 1 RC_TEXT
				    FROM dbo.ReturnCode
				    WHERE RC_NUM = CSD_CODE_CLIENT
					    AND RC_TYPE = 'CLIENT'
				    ORDER BY RC_ID
			    ), '����������� ���') + ')'
		    FROM #client

	    INSERT INTO #stat
		    (
			    MASTER_ID, SYS_ID, SYS_NAME, NODE_NAME, NODE_VALUE
		    )
		    SELECT
			    (
				    SELECT ID
				    FROM #stat
				    WHERE SYS_ID = CSD_ID AND SYS_NAME = @rep
			    ), CSD_ID, NULL, '��� �������',
			    CONVERT(VARCHAR(20), CSD_CODE_SERVER) + ' (' +
			    ISNULL(
				    (
					    SELECT  TOP 1 RC_TEXT
					    FROM dbo.ReturnCode
					    WHERE RC_NUM = CSD_CODE_SERVER
						    AND RC_TYPE = 'SERVER'
					    ORDER BY RC_ID
				    ), '����������� ���') + ')'
		    FROM #client

	    INSERT INTO #stat
		    (
			    MASTER_ID, SYS_ID, SYS_NAME, NODE_NAME, NODE_VALUE, NODE_LINK, STAT
		    )
		    SELECT
			    (
				    SELECT ID
				    FROM #stat
				    WHERE SYS_ID = CSD_ID AND SYS_NAME = @rep
			    ), CSD_ID, @usr, '���� USR',  CASE CSD_USR WHEN '-' THEN '���' ELSE CSD_USR END,
			    CSD_USR, CASE CSD_USR WHEN '-' THEN 0 ELSE 7 END
		    FROM #client

	    INSERT INTO #stat
		    (
			    MASTER_ID, SYS_ID, SYS_NAME, NODE_NAME, NODE_VALUE, NODE_LINK, STAT
		    )
		    SELECT
			    (
				    SELECT ID
				    FROM #stat
				    WHERE SYS_ID = CSD_ID AND SYS_NAME = @usr
			    ), CSD_ID, NULL, '���� cons_err.txt', CASE CSD_USR WHEN '-' THEN '���' ELSE '�������' END,
			    (
				    SELECT SRV_REPORT
				    FROM dbo.Servers
				    WHERE SRV_ID = CSD_ID_SERVER
			    ) + CSD_USR, CASE CSD_USR WHEN '-' THEN 0 ELSE 8 END
		    FROM #client

	    INSERT INTO #stat
		    (
			    MASTER_ID, SYS_ID, SYS_NAME, NODE_NAME, NODE_VALUE, NODE_LINK, STAT
		    )
		    SELECT
			    (
				    SELECT ID
				    FROM #stat
				    WHERE SYS_ID = CSD_ID AND SYS_NAME = @usr
			    ), CSD_ID, NULL, '���� cons_inet.txt', CASE CSD_USR WHEN '-' THEN '���' ELSE '�������' END,
			    (
				    SELECT SRV_REPORT
				    FROM dbo.Servers
				    WHERE SRV_ID = CSD_ID_SERVER
			    ) + CSD_USR, CASE CSD_USR WHEN '-' THEN 0 ELSE 9 END
		    FROM #client
	    /*
	    INSERT INTO #stat
		    (
			    MASTER_ID, SYS_ID, SYS_NAME, NODE_NAME, NODE_VALUE, NODE_LINK, STAT
		    )
		    SELECT
			    (
				    SELECT ID
				    FROM #stat
				    WHERE SYS_ID = CSD_ID AND SYS_NAME = @usr
			    ), CSD_ID, NULL, '���� cons_inet_listfiles.txt', CASE CSD_USR WHEN '-' THEN '���' ELSE '�������' END,
			    (
				    SELECT SRV_REPORT
				    FROM dbo.Servers
				    WHERE SRV_ID = CSD_ID_SERVER
			    ) + CSD_USR, CASE CSD_USR WHEN '-' THEN 0 ELSE 10 END
		    FROM #client
	    */

	    SELECT ID, MASTER_ID, NODE_NAME, NODE_VALUE, NODE_LINK, SRV, STAT
	    FROM #stat
	    ORDER BY ID
    

	    IF OBJECT_ID('tempdb..#client') IS NOT NULL
		    DROP TABLE #client

	    IF OBJECT_ID('tempdb..#stat') IS NOT NULL
		    DROP TABLE #stat

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [dbo].[CLIENT_STAT_SELECT] TO rl_client_stat;
GO
