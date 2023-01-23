USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[dbo].[SubhostEmail_Type@Update]', 'P ') IS NULL EXEC('CREATE PROCEDURE [dbo].[SubhostEmail_Type@Update]  AS SELECT 1')
GO
CREATE   PROCEDURE [dbo].[SubhostEmail_Type@Update]
	@Id TinyInt,
	@Code VarChar(8000),
	@Name VarChar(8000)
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
		@DebugContext	= @DebugContext OUT;

	BEGIN TRY

		UPDATE	[dbo].[SubhostEmail_Type] SET
			[Code]	= @Code,
			[Name]	= @Name
		WHERE	[Id]	=	@Id;

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [dbo].[SubhostEmail_Type@Update] TO rl_subhost_email_type_u;
GO
