USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[Security].[SEARCH_SAVE]', 'P ') IS NULL EXEC('CREATE PROCEDURE [Security].[SEARCH_SAVE]  AS SELECT 1')
GO
ALTER PROCEDURE [Security].[SEARCH_SAVE]
	@TYPE	NVARCHAR(64),
	@SHORT	VARCHAR(250),
	@SEARCH	XML
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

		INSERT INTO Security.ClientSearch(CS_TYPE, CS_SHORT, CS_SEARCH)
			VALUES(@TYPE, @SHORT, @SEARCH)

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [Security].[SEARCH_SAVE] TO public;
GO
