USE [IPLogs]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[USR_FILE_HASH_SET]
	--@ID		UNIQUEIDENTIFIER,
	@ID		INT,
	@HASH	VARCHAR(100)
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
	    /*
	    UPDATE USR.USRFile
	    SET UF_HASH = @HASH
	    WHERE UF_HASH IS NULL
		    AND UF_ID = @ID;
	    */

	    UPDATE dbo.USRFiles
	    SET UF_MD5 = @HASH
	    WHERE UF_MD5 IS NULL
		    AND UF_ID = @ID

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
