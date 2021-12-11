USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[dbo].[USR_FILE_KIND_INSERT]', 'P ') IS NULL EXEC('CREATE PROCEDURE [dbo].[USR_FILE_KIND_INSERT]  AS SELECT 1')
GO
ALTER PROCEDURE [dbo].[USR_FILE_KIND_INSERT]
	@NAME	VARCHAR(100),
	@SNAME	VARCHAR(100),
	@SHORT	VARCHAR(100),
	@ID	INT = NULL OUTPUT
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

		INSERT INTO dbo.USRFileKindTable(USRFileKindName, USRFileKindShortName, USRFileKindShort)
			VALUES(@NAME, @SNAME, @SHORT)

		SELECT @ID = SCOPE_IDENTITY()

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH

END
GO
GRANT EXECUTE ON [dbo].[USR_FILE_KIND_INSERT] TO rl_usr_kind_i;
GO
