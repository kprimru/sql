USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[USR].[GROUP_PARAMS_INSERT]', 'P ') IS NULL EXEC('CREATE PROCEDURE [USR].[GROUP_PARAMS_INSERT]  AS SELECT 1')
GO




ALTER PROCEDURE [USR].[GROUP_PARAMS_INSERT]
	@Group_Id	TinyInt,
	@Code		VarChar(100),
	@Name		VarChar(100),
	@SortIndex	TinyInt,
	@FieldName	VarChar(100),
	@ErrorCode	VarChar(20),
	@ID			TinyInt = NULL OUTPUT
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

		INSERT INTO [USR].[Groups_Params]([Group_Id], [Code], [Name], [SortIndex], FieldName, ErrorCode)
		VALUES(@Group_Id, @Code, @Name, @SortIndex, @FieldName, @ErrorCode);

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
GRANT EXECUTE ON [USR].[GROUP_PARAMS_INSERT] TO rl_usr_group_params_i;
GO
