USE [IPLogs]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[PROCESS_FILES]
	@FILES	NVARCHAR(MAX),
	@SERVER	INT
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

	    DECLARE @LEN INT
    
	    SET @LEN = LEN(@FILES)
    
	    DECLARE @LSTR VARCHAR(50)
    
	    SET @LSTR = CONVERT(VARCHAR(50), @LEN)
    
	    --RAISERROR(@LSTR, 16, 1)
    
	    --RETURN

	    DECLARE @XML XML
	    DECLARE @HDOC INT
    
	    SET @XML = CAST(@FILES AS XML)

	    EXEC sp_xml_preparedocument @HDOC OUTPUT, @XML

	    IF OBJECT_ID('tempdb..#filelist') IS NOT NULL
		    DROP TABLE #filelist

	    CREATE TABLE #filelist
		    (
			    FILE_PATH	NVARCHAR(512),
			    FILE_SIZE	BIGINT,
			    /*
				    тип файла - 3-х видов:
					    CLIENT
					    SERVER
					    LOG
			    */
			    FILE_TYPE	NVARCHAR(64)
		    )

	    INSERT INTO #filelist
		    (
			    FILE_PATH, FILE_SIZE, FILE_TYPE
		    )
		    SELECT 
			    c.value('(@NAME)', 'NVARCHAR(512)') AS FILE_PATH,
			    c.value('(@SIZE)', 'BIGINT') AS FILE_SIZE,
			    c.value('(@TYPE)', 'NVARCHAR(64)') AS FILE_TYPE
		    FROM @xml.nodes('/FILELIST/FILE') AS a(c)

	    DECLARE FILES CURSOR LOCAL FOR
		    SELECT FILE_PATH, FILE_SIZE, FILE_TYPE
		    FROM #filelist
		    WHERE FILE_TYPE IN ('CLIENT', 'SERVER', 'LOG')
			    AND NOT EXISTS
				    (
					    SELECT *
					    FROM dbo.Files
					    WHERE FL_NAME = FILE_PATH
						    AND FL_SIZE = FILE_SIZE
				    )
    
	    OPEN FILES

	    DECLARE @FILE_PATH	NVARCHAR(512)
	    DECLARE @FILE_SIZE	BIGINT
	    DECLARE @FILE_TYPE	NVARCHAR(64)

	    FETCH NEXT FROM FILES INTO
		    @FILE_PATH, @FILE_SIZE, @FILE_TYPE

	    DECLARE @SERVER_PATH	NVARCHAR(512)

	    IF @SERVER IS NULL
		    SELECT @SERVER_PATH = ST_VALUE
		    FROM dbo.Settings
		    WHERE ST_NAME = N'SERVER_PATH'
	    ELSE
		    SELECT @SERVER_PATH = SRV_PATH
		    FROM dbo.Servers
		    WHERE SRV_ID = @SERVER

	    WHILE @@FETCH_STATUS = 0
	    BEGIN
		    SET @FILE_PATH = @SERVER_PATH + @FILE_PATH

		    IF @FILE_TYPE = 'LOG'
		    BEGIN
			    EXEC dbo.LOG_FILE_PROCESS @FILE_PATH, @FILE_SIZE, @SERVER
		    END
		    ELSE IF @FILE_TYPE = 'CLIENT'
		    BEGIN
			    EXEC dbo.CLIENT_FILE_PROCESS @FILE_PATH, @FILE_SIZE, @SERVER
		    END
		    ELSE IF @FILE_TYPE = 'SERVER'
		    BEGIN
			    EXEC dbo.SERVER_FILE_PROCESS @FILE_PATH, @FILE_SIZE, @SERVER
		    END

		    FETCH NEXT FROM FILES INTO
			    @FILE_PATH, @FILE_SIZE, @FILE_TYPE
	    END

	    CLOSE FILES
	    DEALLOCATE FILES

	    IF OBJECT_ID('tempdb..#filelist') IS NOT NULL
		    DROP TABLE #filelist

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [dbo].[PROCESS_FILES] TO rl_ip_refresh;
GO
