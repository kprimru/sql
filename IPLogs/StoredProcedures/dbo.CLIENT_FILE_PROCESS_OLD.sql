USE [IPLogs]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[CLIENT_FILE_PROCESS_OLD]
	@FILENAME	NVARCHAR(512),
	@FILESIZE	BIGINT,
	@SERVER		INT = NULL
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

	    DECLARE @FILEID	INT
	    DECLARE @RESULT	TINYINT

	    EXEC dbo.FILE_PROCESS @SERVER, @FILENAME, @FILESIZE, 2, @FILEID OUTPUT, @RESULT OUTPUT

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
		    CSD_IP_MODE NVARCHAR(64)/*,
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

	    DECLARE @ROW CHAR

	    SET @ROW = CHAR(10)

	    EXEC('
	    BULK INSERT #csd
	    FROM ''' + @FILENAME + '''
		    WITH
			    (
				    FIRSTROW = 2,
				    ROWTERMINATOR = ''' + @ROW + ''',
				    FIELDTERMINATOR = '';'',
				    CODEPAGE = 1251
			    )')

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
			    CSD_IP_MODE
		    )
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
		    CSD_IP_MODE
	    FROM #csd a
	    WHERE NOT EXISTS
		    (
			    SELECT *
			    FROM dbo.ClientStatDetail b
			    WHERE CSD_ID_CS = @STATID
				    AND a.CSD_NUM = b.CSD_NUM
		    )
	    ORDER BY CSD_NUM


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
