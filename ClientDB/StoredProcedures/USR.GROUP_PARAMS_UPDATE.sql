USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[USR].[GROUP_PARAMS_UPDATE]', 'P ') IS NULL EXEC('CREATE PROCEDURE [USR].[GROUP_PARAMS_UPDATE]  AS SELECT 1')
GO


ALTER PROCEDURE [USR].[GROUP_PARAMS_UPDATE]
	@ID			TinyInt,
	@Group_Id	TinyInt,
	@Code		VarChar(100),
	@Name		VarChar(100),
	@SortIndex	TinyInt,
	@FieldName	VarChar(100),
	@ErrorCode	VarChar(20)
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
		UPDATE [USR].[Groups_Params]
		SET
			[Group_Id]	= @Group_Id,
			[Name]		= @Name,
			[Code]		= @Code,
			[SortIndex]	= @SortIndex,
			[FieldName] = @FieldName,
			[ErrorCode] = @ErrorCode
		WHERE [Id] = @Id;

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [USR].[GROUP_PARAMS_UPDATE] TO rl_usr_group_params_u;
GO
