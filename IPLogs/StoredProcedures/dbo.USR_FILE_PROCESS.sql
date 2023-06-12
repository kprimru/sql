USE [IPLogs]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[dbo].[USR_FILE_PROCESS]', 'P ') IS NULL EXEC('CREATE PROCEDURE [dbo].[USR_FILE_PROCESS]  AS SELECT 1')
GO
ALTER PROCEDURE [dbo].[USR_FILE_PROCESS]
	@SERVER		INT,
	@FILENAME	NVARCHAR(512),
	@FILESIZE	BIGINT,
	@USR_NAME	NVARCHAR(128),
	@USR_DATA	VARBINARY(MAX),
	@ERROR_DATA	NVARCHAR(MAX),
	@LOG_DATA	NVARCHAR(MAX) = NULL,
	@FILEMD5	NVARCHAR(32)
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

	    DECLARE @FILEID	INT
	    DECLARE @RESULT	TINYINT

	    EXEC dbo.FILE_PROCESS @SERVER, @FILENAME, @FILESIZE, 4, @FILEID OUTPUT, @RESULT OUTPUT

		SET @DebugComment = 'FileName = ' + @FILENAME;
		EXEC [Debug].[Execution@Point]
			@DebugContext	= @DebugContext,
			@Name			= @DebugComment;

	    IF @FILEID IS NOT NULL
	    BEGIN
		    IF @RESULT = 1
		    BEGIN
			    UPDATE dbo.USRFiles
			    SET /*UF_ERROR_LOG = @ERROR_DATA,*/
				    UF_USR_DATA	= @USR_DATA,
				    UF_MD5 = @FILEMD5/*,
				    UF_INET_LOG = @LOG_DATA*/
			    WHERE UF_ID_FILE = @FILEID
    
			    UPDATE dbo.ConsErr
			    SET --ERROR_DATA = @ERROR_DATA,
					ERROR_DATA_COMPRESSED = Compress(@ERROR_DATA),
				    --INET_LOG_DATA = @LOG_DATA,
					INET_LOG_DATA_COMPRESSED = Compress(@LOG_DATA)
			    WHERE ID_USR = (SELECT UF_ID FROM dbo.USRFiles WHERE UF_ID_FILE = @FILEID)
    
			    IF @@ROWCOUNT = 0
				    INSERT INTO dbo.ConsErr(ID_USR, ERROR_DATA_COMPRESSED, INET_LOG_DATA_COMPRESSED)
					    SELECT UF_ID, Compress(@ERROR_DATA), Compress(@LOG_DATA)
					    FROM dbo.USRFiles
					    WHERE UF_ID_FILE = @FILEID
		    END
		    ELSE IF (@RESULT = 2) OR (@RESULT = 0)
		    BEGIN
			    DECLARE @ID	INT
    
			    INSERT INTO dbo.USRFiles(UF_ID_FILE, UF_USR_NAME, UF_USR_DATA, /*UF_ERROR_LOG, UF_INET_LOG, */UF_DATE, UF_SYS, UF_DISTR, UF_COMP, UF_MD5)
				    SELECT
					    @FILEID, @USR_NAME, @USR_DATA, /*@ERROR_DATA, @LOG_DATA, */
					    CONVERT(DATETIME, dbo.USR_PARSE(@FILENAME, 'DATE'), 120),
					    CONVERT(SMALLINT, dbo.USR_PARSE(@FILENAME, 'SYS')),
					    CONVERT(INT, dbo.USR_PARSE(@FILENAME, 'DISTR')),
					    CONVERT(TINYINT, dbo.USR_PARSE(@FILENAME, 'COMP')),
					    @FILEMD5
    
			    SELECT @ID = SCOPE_IDENTITY()
    
			    INSERT INTO dbo.ConsErr(ID_USR, /*ERROR_DATA, */ERROR_DATA_COMPRESSED, /*INET_LOG_DATA, */INET_LOG_DATA_COMPRESSED)
				    SELECT @ID, /*@ERROR_DATA, */Compress(@ERROR_DATA), /*@LOG_DATA, */Compress(@LOG_DATA)
				    FROM dbo.USRFiles
				    WHERE UF_ID_FILE = @FILEID
		    END
    
			-- ToDo MERGE
		    UPDATE [ClientDB].[IP].[ConsErr]
		    SET DATE = CONVERT(DATETIME, dbo.USR_PARSE(@FILENAME, 'DATE'), 120)
		    WHERE SYS = CONVERT(SMALLINT, dbo.USR_PARSE(@FILENAME, 'SYS'))
			    AND DISTR = CONVERT(INT, dbo.USR_PARSE(@FILENAME, 'DISTR'))
			    AND COMP = CONVERT(TINYINT, dbo.USR_PARSE(@FILENAME, 'COMP'))
    
		    IF @@ROWCOUNT = 0
			    INSERT INTO [ClientDB].[IP].[ConsErr]
			    SELECT
				    CONVERT(SMALLINT, dbo.USR_PARSE(@FILENAME, 'SYS')), CONVERT(INT, dbo.USR_PARSE(@FILENAME, 'DISTR')),
				    CONVERT(TINYINT, dbo.USR_PARSE(@FILENAME, 'COMP')), CONVERT(DATETIME, dbo.USR_PARSE(@FILENAME, 'DATE'), 120)
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
