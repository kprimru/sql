USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[SEARCH_SELECT]
	@BEGIN	DATETIME = NULL,
	@END	DATETIME = NULL,
	@CATEGORY VARCHAR(50) = NULL,
	@USER	VARCHAR(50) = NULL,
	@HOST	VARCHAR(50) = NULL
WITH EXECUTE AS OWNER
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

		IF @BEGIN IS NULL
			SET @BEGIN = DATEADD(DAY, -5, GETDATE())

		IF @END IS NULL
			SET @END = GETDATE()

		IF @USER IS NULL
			SET @USER = ORIGINAL_LOGIN()

		IF @HOST IS NULL
			SET @HOST = HOST_NAME()

		SELECT MAX(SearchDateTime) AS SearchDateTime, SearchCategory, SearchText
		FROM dbo.SearchTable
		WHERE SearchDateTime >= @BEGIN
			AND SearchDateTime <= @END
			AND SearchUser = @USER
			AND SearchHost = @HOST
		GROUP BY SearchCategory, SearchText
		ORDER BY SearchDateTime DESC

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [dbo].[SEARCH_SELECT] TO public;
GO
