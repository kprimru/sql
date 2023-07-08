USE [IPLogs]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[dbo].[CLIENT_FILE_PROCESS]', 'P ') IS NULL EXEC('CREATE PROCEDURE [dbo].[CLIENT_FILE_PROCESS]  AS SELECT 1')
GO
ALTER PROCEDURE [dbo].[CLIENT_FILE_PROCESS]
	@FILENAME	NVarChar(512),
	@FILESIZE	BigInt,
	@SERVER		Int,
	@FILEPATH	NVarChar(512)
AS
BEGIN
	SET NOCOUNT ON;

    DECLARE
		@DebugError		VarChar(512),
		@DebugComment	VarChar(512),
		@DebugContext	Xml,
		@Params			Xml;

	EXEC [Debug].[Execution@Start]
		@Proc_Id		= @@ProcId,
		@Params			= @Params,
		@DebugContext	= @DebugContext OUT

	BEGIN TRY

	    DECLARE
			@FILEID	Int,
			@RESULT	TinyInt

	    DECLARE @IDs Table
	    (
		    [Id]	BigInt	NOT NULL,
		    Primary Key Clustered([Id])
	    );
    
		SET @DebugComment = '@FILENAME = ' + @FILENAME + ' @FILESIZE = ' + Cast(@FILESIZE AS VarChar(Max)) + ' @SERVER = ' + Cast(@SERVER AS VarChar(Max));
		EXEC [Debug].[Execution@Point]
			@DebugContext	= @DebugContext,
			@Name			= @DebugComment;

	    EXEC dbo.FILE_PROCESS @SERVER, @FILENAME, @FILESIZE, 2, @FILEID OUTPUT, @RESULT OUTPUT

		SET @DebugComment = 'EXEC dbo.FILE_PROCESS';
		EXEC [Debug].[Execution@Point]
			@DebugContext	= @DebugContext,
			@Name			= @DebugComment;

	    IF (@FILEID IS NULL) OR (@RESULT = 0)
	    BEGIN
		    RETURN
	    END

	    IF OBJECT_ID('tempdb..#csd') IS NOT NULL
		    DROP TABLE #csd

	    CREATE TABLE #csd(
		    CSD_NUM BIGINT,
		    CSD_SYS SMALLINT,
		    CSD_DISTR INT,
		    CSD_COMP NVARCHAR(10),
		    CSD_IP NVARCHAR(50),
		    CSD_SESSION NVARCHAR(50),
		    CSD_START_DATE NVARCHAR(50),--DATETIME,
		    CSD_START_TIME NVARCHAR(50),--DATETIME,
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
		    CSD_END_DATE NVARCHAR(64),
		    CSD_END_TIME NVARCHAR(64),
		    CSD_REDOWNLOAD BIT,
		    CSD_LOG_PATH NVARCHAR(256),
		    CSD_LOG_FILE NVARCHAR(256),
		    CSD_LOG_RESULT NVARCHAR(256),
		    CSD_LOG_LETTER NVARCHAR(256),
		    CSD_USR NVARCHAR(256),
		    CSD_CODE_CLIENT INT,
		    CSD_CODE_SERVER INT,
		    CSD_IP_MODE NVARCHAR(64),
		    /*
		    эти два поля действуют только с марта 2013.
		    */
		    CSD_RES_VERSION	NVARCHAR(64),
		    CSD_DOWNLOAD_SPEED	NVARCHAR(512),
		    /*
		    эти три поля - с июля 2013
		    */
		    CSD_STT_SEND VARCHAR(20),
		    CSD_STT_RESULT VARCHAR(20),
		    CSD_INET_EXT VARCHAR(255)--,
		    /*
		    эти 2 поля - с 28 октября 2014
		    */
		    --CSD_PROXY_METOD	NVARCHAR(128),
		    --CSD_PROXY_INTERFACE	NVARCHAR(128)
    
		    /*,
    
		    CONSTRAINT [PK_CLIENT_STAT_NUM] PRIMARY KEY CLUSTERED
			    (
				    [CSD_NUM] ASC
			    ) WITH
				    (
					    PAD_INDEX  = OFF,
					    STATISTICS_NORECOMPUTE  = OFF,
					    IGNORE_DUP_KEY = OFF,
					    ALLOW_ROW_LOCKS  = ON,
					    ALLOW_PAGE_LOCKS  = ON
				    ) ON [PRIMARY]*/
		    ) ON [PRIMARY]

		SET @DebugComment = 'BEFORE BULK INSERT';
		EXEC [Debug].[Execution@Point]
			@DebugContext	= @DebugContext,
			@Name			= @DebugComment;

	    DECLARE @ROW CHAR

	    SET @ROW = CHAR(10)

	    EXEC('
	    BULK INSERT #csd
	    FROM ''' + @FILEPATH + '''
		    WITH
			    (
				    FIRSTROW = 2,
				    ROWTERMINATOR = ''' + @ROW + ''',
				    FIELDTERMINATOR = '';'',
				    CODEPAGE = 1251,
				    KEEPNULLS
			    )')

		SET @DebugComment = 'AFTER BULK INSERT';
		EXEC [Debug].[Execution@Point]
			@DebugContext	= @DebugContext,
			@Name			= @DebugComment;

	    DECLARE @STATID	INT

	    SELECT @STATID = CS_ID
	    FROM dbo.ClientStat
	    WHERE CS_ID_FILE = @FILEID

	    IF @STATID IS NULL
	    BEGIN
		    INSERT INTO dbo.ClientStat(CS_ID_FILE)
			    VALUES(@FILEID)

		    SELECT @STATID = SCOPE_IDENTITY()
	    END

		SET @DebugComment = 'INSERT INTO dbo.ClientStat(CS_ID_FILE)';
		EXEC [Debug].[Execution@Point]
			@DebugContext	= @DebugContext,
			@Name			= @DebugComment;

	    INSERT INTO dbo.ClientStatDetail
		    (
			    CSD_ID_CS,
			    CSD_NUM, CSD_SYS, CSD_DISTR, CSD_COMP,
			    CSD_IP, CSD_SESSION,
			    CSD_START, CSD_QST_TIME, CSD_QST_SIZE,
			    CSD_ANS_TIME, CSD_ANS_SIZE,
			    CSD_CACHE_TIME, CSD_CACHE_SIZE,
			    CSD_DOWNLOAD_TIME, CSD_UPDATE_TIME,
			    CSD_REPORT_TIME, CSD_REPORT_SIZE,
			    CSD_END,
			    CSD_REDOWNLOAD,
			    CSD_LOG_PATH, CSD_LOG_FILE, CSD_LOG_RESULT, CSD_LOG_LETTER,
			    CSD_USR,
			    CSD_CODE_CLIENT, CSD_CODE_SERVER,
			    CSD_IP_MODE, CSD_RES_VERSION, CSD_DOWNLOAD_SPEED,
			    CSD_STT_SEND, CSD_STT_RESULT, CSD_INET_EXT--, CSD_PROXY_METOD, CSD_PROXY_INTERFACE
		    )
	    OUTPUT inserted.CSD_ID INTO @IDs
	    SELECT
		    @STATID,
		    CSD_NUM, CSD_SYS, CSD_DISTR,
		    CASE CSD_COMP
			    WHEN '-' THEN 1
			    ELSE CONVERT(SMALLINT, CSD_COMP)
		    END,
		    CSD_IP, CSD_SESSION,
		    CONVERT(DATETIME,
				    LEFT(CONVERT(VARCHAR(50),
						    CASE CSD_START_DATE
							    WHEN '-' THEN NULL
							    WHEN '0' THEN NULL
							    ELSE CONVERT(DATETIME, CSD_START_DATE, 104)
						    END, 121), 10) + ' ' +
				    RIGHT(CONVERT(VARCHAR(50),
						    CASE CSD_START_TIME
							    WHEN '-' THEN NULL
							    WHEN '0' THEN NULL
							    ELSE CONVERT(DATETIME, CSD_START_TIME, 121)
						    END, 121), 12)
			    , 121)
			    AS CSD_START_DATETIME,
		    CSD_QST_TIME, CSD_QST_SIZE,
		    CSD_ANS_TIME, CSD_ANS_SIZE,
		    CSD_CACHE_TIME, CSD_CACHE_SIZE,
		    CSD_DOWNLOAD_TIME, CSD_UPDATE_TIME,
		    CSD_REPORT_TIME, CSD_REPORT_SIZE,
		    CONVERT(DATETIME,
				    LEFT(CONVERT(VARCHAR(50),
						    CASE CSD_END_DATE
							    WHEN '-' THEN NULL
							    WHEN '0' THEN NULL
							    ELSE CONVERT(DATETIME, CSD_END_DATE, 104)
						    END, 121), 10) + ' ' +
				    RIGHT(CONVERT(VARCHAR(50),
						    CASE CSD_END_TIME
							    WHEN '-' THEN NULL
							    WHEN '0' THEN NULL
							    ELSE CONVERT(DATETIME, CSD_END_TIME, 121)
						    END, 121), 12)
			    , 121)
			    AS CSD_END_DATETIME,	 
		    CSD_REDOWNLOAD,
		    CSD_LOG_PATH, CSD_LOG_FILE, CSD_LOG_RESULT, CSD_LOG_LETTER,
		    CSD_USR,
		    CSD_CODE_CLIENT, CSD_CODE_SERVER,
		    CSD_IP_MODE, CSD_RES_VERSION,
			    CASE CHARINDEX(';', CSD_DOWNLOAD_SPEED)
				    WHEN 0 THEN CSD_DOWNLOAD_SPEED
				    ELSE LEFT(CSD_DOWNLOAD_SPEED, CHARINDEX(';', CSD_DOWNLOAD_SPEED) - 1)
			    END,
		    CASE
			    WHEN CSD_STT_SEND LIKE 'TRUE%' THEN 1
			    WHEN CSD_STT_SEND LIKE 'FALSE%' THEN 0
			    ELSE NULL
		    END,
		    CASE
			    WHEN CSD_STT_RESULT LIKE 'TRUE%' THEN 1
			    WHEN CSD_STT_RESULT LIKE 'FALSE%' THEN 0
			    ELSE NULL
		    END,
		    CASE
			    WHEN CSD_INET_EXT LIKE 'TRUE%' THEN 1
			    WHEN CSD_INET_EXT LIKE 'FALSE%' THEN 0
			    ELSE NULL END--,
		    --CSD_PROXY_METOD, CSD_PROXY_INTERFACE
	    FROM #csd a
	    WHERE NOT EXISTS
		    (
			    SELECT *
			    FROM dbo.ClientStatDetail b
			    WHERE CSD_ID_CS = @STATID
				    AND a.CSD_NUM = b.CSD_NUM
				    AND a.CSD_SYS = b.CSD_SYS
				    AND a.CSD_DISTR = b.CSD_DISTR
				    AND a.CSD_COMP = b.CSD_COMP
		    )
	    ORDER BY CSD_NUM
    
		SET @DebugComment = 'INSERT INTO dbo.ClientStatDetail';
		EXEC [Debug].[Execution@Point]
			@DebugContext	= @DebugContext,
			@Name			= @DebugComment;

	    --ВОТ СЮДА ПОДОБНОЕ ТОМУ ЧТО СВЕРХУ, ТОЛЬКО С ЗАМЕНОЙ И В 275TS ClientDB
	    --ЕСЛИ ЧТО УДАЛЯТЬ ВСЕ
	    ---------------------------------------------------------------------------
	    UPDATE b
	    SET	CSD_START				= a.CSD_START,
		    CSD_CODE_CLIENT			= a.CSD_CODE_CLIENT,
		    CSD_CODE_CLIENT_NOTE	= ISNULL((
											    SELECT TOP 1 RC_TEXT
											    FROM dbo.ReturnCode
											    WHERE RC_NUM = a.CSD_CODE_CLIENT
												    AND RC_TYPE = 'CLIENT'
											    ORDER BY RC_ID
										    ), 'неизвестный код'),
		    CSD_USR					= a.CSD_USR
	    FROM [ClientDB].[IP].[ClientStatDetailCache] b
	    INNER JOIN dbo.ClientStatDetail a ON b.CSD_SYS = a.CSD_SYS AND b.CSD_DISTR = a.CSD_DISTR AND b.CSD_COMP = a.CSD_COMP
	    INNER JOIN @IDs I ON a.CSD_ID = I.Id;

	    INSERT INTO [ClientDB].[IP].[ClientStatDetailCache] (CSD_SYS, CSD_DISTR, CSD_COMP, CSD_START, CSD_CODE_CLIENT, CSD_CODE_CLIENT_NOTE, CSD_USR)
	    SELECT
		    a.CSD_SYS,
		    a.CSD_DISTR,
		    a.CSD_COMP,
		    a.CSD_START,
		    a.CSD_CODE_CLIENT,
		    ISNULL((SELECT TOP 1 RC_TEXT
                    FROM dbo.ReturnCode
                    WHERE RC_NUM = a.CSD_CODE_CLIENT
                          AND RC_TYPE = 'CLIENT'
                    ORDER BY RC_ID
                    ), 'неизвестный код'),
		    a.CSD_USR
	    FROM
	    (
		    SELECT DISTINCT CSD_SYS, CSD_DISTR, CSD_COMP
		    FROM @IDs I
		    INNER JOIN dbo.ClientStatDetail a ON a.CSD_ID = I.Id
	    ) I
	    CROSS APPLY
	    (
		    SELECT TOP (1) a.CSD_SYS, a.CSD_DISTR, a.CSD_COMP, a.CSD_START, a.CSD_CODE_CLIENT, a.CSD_USR
		    FROM dbo.ClientStatDetail a
		    WHERE a.CSD_SYS = I.CSD_SYS
			    AND a.CSD_DISTR = I.CSD_DISTR
			    AND a.CSD_COMP = I.CSD_COMP
		    ORDER BY CSD_START DESC
	    ) a
	    WHERE NOT EXISTS
		    (
			    SELECT *
			    FROM [ClientDB].[IP].[ClientStatDetailCache] b
			    WHERE b.CSD_SYS=a.CSD_SYS AND b.CSD_DISTR=a.CSD_DISTR AND b.CSD_COMP=a.CSD_COMP
		    )
    
	    INSERT INTO [ClientDB].[IP].[ClientStatSTTCache] (CSD_SYS, CSD_DISTR, CSD_COMP, CSD_START, CSD_END)
	    SELECT
		    a.CSD_SYS,
		    a.CSD_DISTR,
		    a.CSD_COMP,
		    a.CSD_START,
		    a.CSD_END
	    FROM  dbo.ClientStatDetail a
	    INNER JOIN @IDs I ON a.CSD_ID = I.Id
	    WHERE NOT EXISTS
		    (
			    SELECT *
			    FROM [ClientDB].[IP].[ClientStatSTTCache] b
			    WHERE	b.CSD_SYS = a.CSD_SYS
				    AND b.CSD_DISTR = a.CSD_DISTR
				    AND b.CSD_COMP = a.CSD_COMP
				    AND b.CSD_START = a.CSD_START
		    ) AND CSD_START IS NOT NULL
		    AND CSD_STT_SEND = 1
		    AND CSD_STT_RESULT = 1
	    ---------------------------------------------------------------------------

		SET @DebugComment = 'UPDATE CACHE';
		EXEC [Debug].[Execution@Point]
			@DebugContext	= @DebugContext,
			@Name			= @DebugComment;

	    IF OBJECT_ID('tempdb..#csd') IS NOT NULL
		    DROP TABLE #csd

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
