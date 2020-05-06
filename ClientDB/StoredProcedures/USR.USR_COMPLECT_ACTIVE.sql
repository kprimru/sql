USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [USR].[USR_COMPLECT_ACTIVE]
	@UD_ID	INT
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

		UPDATE USR.USRData
		SET UD_ACTIVE =
				CASE UD_ACTIVE
					WHEN 1 THEN 0
					WHEN 0 THEN 1
					ELSE NULL
				END
		WHERE UD_ID = @UD_ID

        EXEC [USR].[USR_ACTIVE_CACHE_REBUILD] @UD_ID = @UD_ID;

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GRANT EXECUTE ON [USR].[USR_COMPLECT_ACTIVE] TO rl_tech_info_complect;
GO