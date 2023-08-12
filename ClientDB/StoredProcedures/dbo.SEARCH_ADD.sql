USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[dbo].[SEARCH_ADD]', 'P ') IS NULL EXEC('CREATE PROCEDURE [dbo].[SEARCH_ADD]  AS SELECT 1')
GO
CREATE OR ALTER PROCEDURE [dbo].[SEARCH_ADD]
	@CAT	VARCHAR(50),
	@TXT	VARCHAR(250)
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

		INSERT INTO dbo.SearchTable(SearchCategory, SearchText)
		VALUES(@CAT, @TXT)

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [dbo].[SEARCH_ADD] TO public;
GO
