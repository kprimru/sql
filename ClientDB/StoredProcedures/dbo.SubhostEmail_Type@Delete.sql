USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[dbo].[SubhostEmail_Type@Delete]', 'P ') IS NULL EXEC('CREATE PROCEDURE [dbo].[SubhostEmail_Type@Delete]  AS SELECT 1')
GO
CREATE   PROCEDURE [dbo].[SubhostEmail_Type@Delete]
	@Id	TinyInt
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

		DELETE
		FROM [dbo].[SubhostEmail_Type]
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
GRANT EXECUTE ON [dbo].[SubhostEmail_Type@Delete] TO rl_subhost_email_type_d;
GO
