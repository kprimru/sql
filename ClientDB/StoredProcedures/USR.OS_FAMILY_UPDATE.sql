USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[USR].[OS_FAMILY_UPDATE]', 'P ') IS NULL EXEC('CREATE PROCEDURE [USR].[OS_FAMILY_UPDATE]  AS SELECT 1')
GO
ALTER PROCEDURE [USR].[OS_FAMILY_UPDATE]
	@ID		INT,
	@NAME	VARCHAR(100)
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

		UPDATE USR.OSFamily
		SET OF_NAME = @NAME
		WHERE OF_ID = @ID

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [USR].[OS_FAMILY_UPDATE] TO rl_os_family_u;
GO
