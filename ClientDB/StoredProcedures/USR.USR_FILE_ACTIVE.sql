USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [USR].[USR_FILE_ACTIVE]
	@UF_ID	INT
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

        SET @UD_ID = (SELECT UF_ID_COMPLECT FROM USR.USRFile WHERE UF_ID = @UF_ID);

		UPDATE USR.USRFile
		SET UF_ACTIVE =
				CASE UF_ACTIVE
					WHEN 1 THEN 0
					WHEN 0 THEN 1
					ELSE NULL
				END
		WHERE UF_ID = @UF_ID

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
GRANT EXECUTE ON [USR].[USR_FILE_ACTIVE] TO rl_tech_info_complect;
GO