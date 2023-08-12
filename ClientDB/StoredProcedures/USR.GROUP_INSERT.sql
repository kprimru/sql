USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[USR].[GROUP_INSERT]', 'P ') IS NULL EXEC('CREATE PROCEDURE [USR].[GROUP_INSERT]  AS SELECT 1')
GO

CREATE OR ALTER PROCEDURE [USR].[GROUP_INSERT]
	@Code		VarChar(100),
	@Name		VarChar(100),
	@SortIndex	TinyInt,
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

		INSERT INTO [USR].[Groups]([Code], [Name], [SortIndex])
		VALUES(@Code, @Name, @SortIndex);

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
GRANT EXECUTE ON [USR].[GROUP_INSERT] TO rl_usr_group_i;
GO
