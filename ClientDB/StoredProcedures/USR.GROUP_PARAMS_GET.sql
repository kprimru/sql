USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[USR].[GROUP_PARAMS_GET]', 'P ') IS NULL EXEC('CREATE PROCEDURE [USR].[GROUP_PARAMS_GET]  AS SELECT 1')
GO


ALTER PROCEDURE [USR].[GROUP_PARAMS_GET]
	@ID		INT
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

		SELECT [Group_Id], [Code], [Name], [SortIndex], [FieldName], [ErrorCode]
		FROM [USR].[Groups_Params]
		WHERE [Id] = @ID

		--RETURN SELECT [Name] FROM [USR].[Groups] WHERE Id = @ID

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [USR].[GROUP_PARAMS_GET] TO rl_usr_group_params_r;
GO
