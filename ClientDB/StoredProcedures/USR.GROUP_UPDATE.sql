USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[USR].[GROUP_UPDATE]', 'P ') IS NULL EXEC('CREATE PROCEDURE [USR].[GROUP_UPDATE]  AS SELECT 1')
GO

CREATE OR ALTER PROCEDURE [USR].[GROUP_UPDATE]
	@ID			TinyInt,
	@Code		VarChar(100),
	@Name		VarChar(100),
	@SortIndex	TinyInt
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

		UPDATE [USR].[Groups]
		SET	[Name]		= @Name,
			[Code]		= @Code,
			[SortIndex]	= @SortIndex
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
GRANT EXECUTE ON [USR].[GROUP_UPDATE] TO rl_usr_group_u;
GO
