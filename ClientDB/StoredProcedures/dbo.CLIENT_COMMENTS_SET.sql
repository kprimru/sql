USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[dbo].[CLIENT_COMMENTS_SET]', 'P ') IS NULL EXEC('CREATE PROCEDURE [dbo].[CLIENT_COMMENTS_SET]  AS SELECT 1')
GO
ALTER PROCEDURE [dbo].[CLIENT_COMMENTS_SET]
	@CLIENT INT,
	@COMMENT NVARCHAR(MAX)
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

		SET @XML = CAST(@COMMENT AS XML)

		EXEC sp_xml_preparedocument @HDOC OUTPUT, @XML

		UPDATE dbo.ClientTable
		SET ClientLastUpdate = GETDATE()
		WHERE ClientID = @CLIENT

		UPDATE dbo.ClientSearchComments
		SET CSC_COMMENTS = @XML
		WHERE CSC_ID_CLIENT = @CLIENT

		IF @@ROWCOUNT = 0
			INSERT INTO dbo.CLientSearchComments(CSC_ID_CLIENT, CSC_COMMENTS)
				VALUES(@CLIENT, @XML)

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [dbo].[CLIENT_COMMENTS_SET] TO rl_client_search_comment;
GO
