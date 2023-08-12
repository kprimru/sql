USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[dbo].[SubhostEmail_Type@Select]', 'P ') IS NULL EXEC('CREATE PROCEDURE [dbo].[SubhostEmail_Type@Select]  AS SELECT 1')
GO
CREATE OR ALTER PROCEDURE [dbo].[SubhostEmail_Type@Select]
	@Filter	VarChar(256) = NULL
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

		SELECT Id, Code, Name
		FROM [dbo].[SubhostEmail_Type]
		WHERE  @FILTER IS NULL
			OR [Code] LIKE @FILTER
			OR [Name] LIKE @FILTER;

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [dbo].[SubhostEmail_Type@Select] TO rl_subhost_email_type_r;
GO
