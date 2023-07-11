USE [IPLogs]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[dbo].[LOG_FILE_PROCESS]', 'P ') IS NULL EXEC('CREATE PROCEDURE [dbo].[LOG_FILE_PROCESS]  AS SELECT 1')
GO
ALTER PROCEDURE [dbo].[LOG_FILE_PROCESS]
	@FILENAME	NVarChar(512),
	@FILESIZE	BigInt,
	@SERVER		Int,
	@FILEPATH	NVarChar(512)
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

	    DECLARE
			@FILEID	Int,
			@RESULT	TinyInt,
			@TEXT	NVarChar(MAX);

	    EXEC dbo.FILE_PROCESS @SERVER, @FILENAME, @FILESIZE, 1, @FILEID OUTPUT, @RESULT OUTPUT;

	    IF @FILEID IS NOT NULL
	    BEGIN
		    IF OBJECT_ID('tempdb..#logfile') IS NOT NULL
			    DROP TABLE #logfile
    
		    CREATE TABLE #logfile
			    (
				    LOG_ROW	NVARCHAR(MAX)
			    )

		    EXEC('
		    BULK INSERT #logfile
		    FROM ''' + @FILEPATH + '''
		    WITH
			    (
				    ROWTERMINATOR = ''\n'',
				    CODEPAGE = 1251
			    )')

		    SET @TEXT = N''
    
		    SELECT @TEXT = @TEXT + LOG_ROW + CHAR(10)
		    FROM #logfile

		    IF OBJECT_ID('tempdb..#logfile') IS NOT NULL
			    DROP TABLE #logfile
    
		    DECLARE
			    @LOG_SYS	SmallInt,
			    @LOG_DISTR	Int,
			    @LOG_COMP	TinyInt,
			    @LOG_DATE	DateTime;
    
		    SELECT
			    @LOG_SYS = dbo.LOG_SYS(@FILENAME), @LOG_DISTR = dbo.LOG_DISTR(@FILENAME),
			    @LOG_COMP = dbo.LOG_COMP(@FILENAME), @LOG_DATE = dbo.LOG_DATE(@FILENAME);
    
		    IF @RESULT = 1
		    BEGIN
			    UPDATE dbo.LogFiles
			    SET LF_TEXT = @TEXT
			    WHERE LF_ID_FILE = @FILEID
		    END
		    ELSE IF (@RESULT = 2) OR (@RESULT = 0)
		    BEGIN
			    INSERT INTO dbo.LogFiles(
					    LF_ID_FILE, LF_TEXT, LF_SHORT, LF_DATE, LF_TYPE, LF_SYS, LF_DISTR, LF_COMP
					    )
			    SELECT
				    @FILEID, @TEXT,
				    dbo.LOG_FILE(@FILENAME), dbo.LOG_DATE(@FILENAME),
				    dbo.LOG_TYPE(@FILENAME), dbo.LOG_SYS(@FILENAME),
				    dbo.LOG_DISTR(@FILENAME), dbo.LOG_COMP(@FILENAME)
		    END
	    END

	    EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
