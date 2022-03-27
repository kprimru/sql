USE [IPLogs]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[PROCESS_FILES]
	@FILES		NVarChar(MAX),
	@SERVER		Int
WITH EXECUTE AS OWNER
AS
BEGIN
	SET NOCOUNT ON;

    DECLARE
		@DebugError		VarChar(512),
		@DebugContext	Xml,
		@Params			Xml;

	DECLARE
		@XML			Xml,
		@FILE_PATH		NVarChar(512),
	    @FILE_SIZE		BigInt,
	    @FILE_TYPE		NVarChar(64),
		@SERVER_PATH	NVarChar(512);


	EXEC [Debug].[Execution@Start]
		@Proc_Id		= @@ProcId,
		@Params			= @Params,
		@DebugContext	= @DebugContext OUT

	BEGIN TRY

	    SET @XML = CAST(@FILES AS XML);

		IF @SERVER IS NULL
		    SELECT @SERVER_PATH = ST_VALUE
		    FROM dbo.Settings
		    WHERE ST_NAME = N'SERVER_PATH';
	    ELSE
		    SELECT @SERVER_PATH = SRV_PATH
		    FROM dbo.Servers
		    WHERE SRV_ID = @SERVER;

	    DECLARE FILES CURSOR LOCAL FAST_FORWARD FOR
		SELECT FILE_PATH, FILE_SIZE, FILE_TYPE
		FROM
		(
			SELECT 
				c.value('(@NAME)', 'NVARCHAR(512)') AS FILE_PATH,
				c.value('(@SIZE)', 'BIGINT') AS FILE_SIZE,
				c.value('(@TYPE)', 'NVARCHAR(64)') AS FILE_TYPE
			FROM @xml.nodes('/FILELIST/FILE') AS a(c)
		) AS F
		WHERE F.FILE_TYPE IN ('CLIENT', 'SERVER', 'LOG')
			AND NOT EXISTS
				(
					SELECT *
					FROM dbo.Files
					WHERE FL_NAME = FILE_PATH
						AND FL_SIZE = FILE_SIZE
				);
    
	    OPEN FILES;

	    FETCH NEXT FROM FILES INTO
		    @FILE_PATH, @FILE_SIZE, @FILE_TYPE;

	    WHILE @@FETCH_STATUS = 0
	    BEGIN
		    SET @FILE_PATH = @SERVER_PATH + @FILE_PATH;

		    IF @FILE_TYPE = 'LOG'
		    BEGIN
			    EXEC dbo.LOG_FILE_PROCESS @FILE_PATH, @FILE_SIZE, @SERVER;
		    END
		    ELSE IF @FILE_TYPE = 'CLIENT'
		    BEGIN
			    EXEC dbo.CLIENT_FILE_PROCESS @FILE_PATH, @FILE_SIZE, @SERVER;
		    END
		    ELSE IF @FILE_TYPE = 'SERVER'
		    BEGIN
			    EXEC dbo.SERVER_FILE_PROCESS @FILE_PATH, @FILE_SIZE, @SERVER;
		    END

		    FETCH NEXT FROM FILES INTO
			    @FILE_PATH, @FILE_SIZE, @FILE_TYPE;
	    END

	    CLOSE FILES;
	    DEALLOCATE FILES;

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
