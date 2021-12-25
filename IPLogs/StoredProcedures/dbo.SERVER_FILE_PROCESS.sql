USE [IPLogs]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[SERVER_FILE_PROCESS]
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

	    EXEC dbo.FILE_PROCESS @SERVER, @FILENAME, @FILESIZE, 3, @FILEID OUTPUT, @RESULT OUTPUT

	    IF (@FILEID IS NULL) OR (@RESULT = 0)
	    BEGIN
		    RETURN
	    END

	    IF OBJECT_ID('tempdb..#ssd') IS NOT NULL
		    DROP TABLE #ssd

	    CREATE TABLE #ssd
		    (
			    SSD_NUM BIGINT,
			    SSD_DATE DATETIME,
			    SSD_TIME DATETIME,
			    SSD_HOSTCOUNT SMALLINT,
			    SSD_QUERY SMALLINT,
			    SSD_SESSIONCOUNT SMALLINT,
			    SSD_TRAFIN BIGINT,
			    SSD_TRAFOUT BIGINT/*,
			    CONSTRAINT [PK_SERVER_STAT_NUM] PRIMARY KEY CLUSTERED
				    (
					    [SSD_NUM] ASC
				    ) WITH
				    (
					    PAD_INDEX  = OFF,
					    STATISTICS_NORECOMPUTE  = OFF,
					    IGNORE_DUP_KEY = OFF,
					    ALLOW_ROW_LOCKS  = ON,
					    ALLOW_PAGE_LOCKS  = ON
				    ) ON [PRIMARY]*/
		    ) ON [PRIMARY]

	    DECLARE @ROW CHAR(1)

	    SET @ROW = CHAR(10)

	    EXEC('
		    BULK INSERT #ssd
		    FROM ''' + @FILENAME + '''
			    WITH
				    (
					    FIRSTROW = 2,
					    ROWTERMINATOR = ''' + @ROW + ''',
					    FIELDTERMINATOR = '';'',
					    CODEPAGE = 1251
				    )')

	    CREATE NONCLUSTERED INDEX [IX_SERVER_STAT_NUM] ON #ssd (SSD_NUM)

	    DECLARE @STATID	INT

	    SELECT @STATID = SS_ID
	    FROM dbo.ServerStat
	    WHERE SS_ID_FILE = @FILEID

	    IF @STATID IS NULL
	    BEGIN
		    INSERT INTO dbo.ServerStat(SS_ID_FILE)
			    VALUES(@FILEID)

		    SELECT @STATID = SCOPE_IDENTITY()
	    END

	    INSERT INTO dbo.ServerStatDetail
		    (
			    SSD_ID_SD,
			    SSD_NUM,
			    SSD_DATE, SSD_HOSTCOUNT,
			    SSD_QUERY, SSD_SESSIONCOUNT,
			    SSD_TRAFIN, SSD_TRAFOUT
		    )
		    SELECT
			    @STATID,
			    SSD_NUM,
			    CONVERT(DATETIME,
					    LEFT(CONVERT(VARCHAR(50), SSD_DATE, 121), 10) + ' ' +
					    RIGHT(CONVERT(VARCHAR(50), SSD_TIME, 121), 12)
				    , 121)
				    AS SSD_DATETIME,
			    SSD_HOSTCOUNT,
			    SSD_QUERY, SSD_SESSIONCOUNT,
			    SSD_TRAFIN, SSD_TRAFOUT
		    FROM #ssd a
		    WHERE NOT EXISTS
			    (
				    SELECT *
				    FROM dbo.ServerStatDetail b
				    WHERE SSD_ID_SD = @STATID
					    AND a.SSD_NUM = b.SSD_NUM
			    )
		    ORDER BY SSD_NUM

	    IF OBJECT_ID('tempdb..#ssd') IS NOT NULL
		    DROP TABLE #ssd

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
