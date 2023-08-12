USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[Security].[SEARCH_FREEZE_SELECT]', 'P ') IS NULL EXEC('CREATE PROCEDURE [Security].[SEARCH_FREEZE_SELECT]  AS SELECT 1')
GO
CREATE OR ALTER PROCEDURE [Security].[SEARCH_FREEZE_SELECT]
	@TYPE	NVARCHAR(64)
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

		SELECT CS_ID, CS_SHORT
		FROM Security.ClientSearch
		WHERE CS_TYPE = @TYPE
			AND CS_FREEZE = 1
			AND CS_HOST = HOST_NAME()
			AND CS_USER = ORIGINAL_LOGIN()
		ORDER BY CS_SHORT DESC

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [Security].[SEARCH_FREEZE_SELECT] TO public;
GO
