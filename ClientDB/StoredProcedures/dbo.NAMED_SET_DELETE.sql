USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[dbo].[NAMED_SET_DELETE]', 'P ') IS NULL EXEC('CREATE PROCEDURE [dbo].[NAMED_SET_DELETE]  AS SELECT 1')
GO
CREATE OR ALTER PROCEDURE [dbo].[NAMED_SET_DELETE]
	@REF_NAME	NVARCHAR(128),
	@SET_NAME	NVARCHAR(128)
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

		DECLARE @SET_ID UNIQUEIDENTIFIER

		SELECT @SET_ID=SetId
		FROM dbo.NamedSets
		WHERE SetName=@SET_NAME AND RefNaME=@REF_NAME

		DELETE
		FROM dbo.NamedSets
		WHERE SetName=@SET_NAME AND RefNaME=@REF_NAME

		DELETE
		FROM dbo.NamedSetsItems
		WHERE SetId=@SET_ID

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [dbo].[NAMED_SET_DELETE] TO rl_named_sets_d;
GO
