USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[CLIENT_SEARCH_IMPORT]
	@CLIENTID INT,
	@SEARCH_DATA NVARCHAR(MAX),
	@RC	INT = NULL OUTPUT
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

		DECLARE @XML XML
		DECLARE @HDOC INT

		SET @XML = CAST(@SEARCH_DATA AS XML)

		EXEC sp_xml_preparedocument @HDOC OUTPUT, @XML


		INSERT INTO dbo.ClientSearchTable(ClientID, SearchText, SearchDate, SearchGet)
			SELECT @CLIENTID, S_TEXT, S_DATE, GETDATE()
			FROM
				(
					SELECT
						c.value('(@STRING)', 'VARCHAR(1024)') AS S_TEXT,
						CONVERT(DATETIME, c.value('(@DATE)', 'VARCHAR(50)'), 121) AS S_DATE
					FROM @xml.nodes('/SEARCH/RECORD') AS a(c)
				) AS o_O
			WHERE NOT EXISTS
				(
					SELECT *
					FROM dbo.ClientSearchTable
					WHERE ClientID = @CLIENTID
						AND S_DATE = SearchDate
						AND S_TEXT = SearchText
				)

		SELECT @RC = @@ROWCOUNT

		IF @RC <> 0
			UPDATE dbo.ClientTable
			SET ClientLastUpdate = GETDATE()
			WHERE ClientID = @CLIENTID

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [dbo].[CLIENT_SEARCH_IMPORT] TO rl_client_search_import;
GO
