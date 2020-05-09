USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [USR].[USR_DELETE]
	@ID INT
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE
		@DebugError		VarChar(512),
		@DebugContext	Xml,
		@Params			Xml;

    DECLARE @UD_ID      Int;

	EXEC [Debug].[Execution@Start]
		@Proc_Id		= @@ProcId,
		@Params			= @Params,
		@DebugContext	= @DebugContext OUT

	BEGIN TRY

        SET @UD_ID = (SELECT UF_ID_COMPLECT FROM USR.USRFile WHERE UF_ID = @ID);

		DELETE
		FROM USR.USRUpdates
		WHERE UIU_ID_IB IN
			(
				SELECT UI_ID
				FROM USR.USRIB
				WHERE UI_ID_USR = @ID
			)

		DELETE
		FROM USR.USRIB
		WHERE UI_ID_USR = @ID

		DELETE
		FROM USR.USRPackage
		WHERE UP_ID_USR = @ID

		DELETE
		FROM USR.USRFileData
		WHERE UF_ID = @ID

		DELETE
		FROM USR.USRFileTech
		WHERE UF_ID = @ID

		DELETE
		FROM USR.USRFile
		WHERE UF_ID = @ID

        EXEC [USR].[USR_ACTIVE_CACHE_REBUILD] @UD_ID = @UD_ID;

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
