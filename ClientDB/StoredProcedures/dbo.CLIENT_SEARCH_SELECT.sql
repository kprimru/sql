USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[CLIENT_SEARCH_SELECT]
	@CLIENTID	INT,
	@BEGIN		DATETIME = NULL,
	@END		DATETIME = NULL,
	@TEXT		VARCHAR(100) = NULL,
	@RC			INT = NULL OUTPUT
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

		SELECT SearchText, SearchDate, SearchGet
		FROM dbo.ClientSearchTable
		WHERE ClientID = @CLIENTID
			AND (SearchDate >= @BEGIN OR @BEGIN IS NULL)
			AND (SearchDate < DATEADD(DAY, 1, @END) OR @END IS NULL)
			AND (SearchText LIKE @TEXT OR @TEXT IS NULL)
		ORDER BY SearchDate DESC

		SET @RC = @@ROWCOUNT

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [dbo].[CLIENT_SEARCH_SELECT] TO rl_client_search_r;
GO
