USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[USR].[OS_FAMILY_SELECT]', 'P ') IS NULL EXEC('CREATE PROCEDURE [USR].[OS_FAMILY_SELECT]  AS SELECT 1')
GO
CREATE OR ALTER PROCEDURE [USR].[OS_FAMILY_SELECT]
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

		SELECT OF_ID, OF_NAME
		FROM USR.OSFamily
		WHERE @FILTER IS NULL
			OR OF_NAME LIKE @FILTER
		ORDER BY OF_NAME

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [USR].[OS_FAMILY_SELECT] TO rl_os_family_r;
GO
