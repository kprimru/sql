USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[USR_FILE_KIND_SELECT]
	@FILTER	VARCHAR(100) = NULL
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

		SELECT USRFileKindID, USRFileKindName, USRFileKindShortName, USRFileKindShort
		FROM dbo.USRFileKindTable
		WHERE @FILTER IS NULL
			OR USRFileKindName LIKE @FILTER
			OR USRFileKindShortName LIKE @FILTER
			OR USRFileKindShort LIKE @FILTER
		ORDER BY USRFileKindName

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [dbo].[USR_FILE_KIND_SELECT] TO rl_usr_kind_r;
GO
