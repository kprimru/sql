﻿USE [IPLogs]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[dbo].[FILE_PROCESS]', 'P ') IS NULL EXEC('CREATE PROCEDURE [dbo].[FILE_PROCESS]  AS SELECT 1')
GO
ALTER PROCEDURE [dbo].[FILE_PROCESS]
	@SERVER		INT,
	@FILENAME	NVARCHAR(512),
	@FILESIZE	BIGINT,
	@FILETYPE	TINYINT,
	@FILEID		INT = NULL OUTPUT,
	/*
		Результат выполнения:
		0. Файл уже существует, замена не требуется
		1. Файл уже существует, требуется обновить
		2. Файла не существует, необходимо создать новый
	*/
	@RESULT		TINYINT = NULL OUTPUT
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

	    DECLARE @EXSIZE BIGINT

	    SELECT	@FILEID = FL_ID, @EXSIZE = FL_SIZE
	    FROM	dbo.Files
	    WHERE	FL_NAME = @FILENAME AND FL_ID_SERVER = @SERVER

	    IF @FILEID IS NOT NULL
	    BEGIN
		    IF @EXSIZE <> @FILESIZE
		    BEGIN
				UPDATE	dbo.Files
			    SET		FL_SIZE = @FILESIZE,
					    FL_DATE = GETDATE()
			    WHERE	FL_ID = @FILEID

			    SET @RESULT = 1
		    END
		    ELSE
		    BEGIN
			    SET @RESULT =	0
			    SET @FILEID = NULL
		    END
	    END
	    ELSE
	    BEGIN
		    INSERT INTO dbo.Files(FL_ID_SERVER, FL_NAME, FL_SIZE, FL_DATE, FL_TYPE)
		    VALUES (@SERVER, @FILENAME, @FILESIZE, GETDATE(), @FILETYPE)
    
		    SELECT @FILEID = SCOPE_IDENTITY()

		    SET @RESULT = 2
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
