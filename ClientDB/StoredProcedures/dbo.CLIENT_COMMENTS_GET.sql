USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[dbo].[CLIENT_COMMENTS_GET]', 'P ') IS NULL EXEC('CREATE PROCEDURE [dbo].[CLIENT_COMMENTS_GET]  AS SELECT 1')
GO
CREATE OR ALTER PROCEDURE [dbo].[CLIENT_COMMENTS_GET]
	@CLIENTID	INT
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

		SELECT CM_TEXT, CONVERT(DATETIME, CM_DATE, 121) AS CM_DATE
		FROM
			dbo.ClientTable a
			INNER JOIN dbo.ClientSearchComments b ON a.ClientID = b.CSC_ID_CLIENT CROSS APPLY
			(
				SELECT
					z.value('@TEXT[1]', 'VARCHAR(250)') AS CM_TEXT,
					z.value('@DATE[1]', 'VARCHAR(50)') AS CM_DATE
				FROM CSC_COMMENTS.nodes('/ROOT/COMMENT') x(z)
			) AS o_O
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
GRANT EXECUTE ON [dbo].[CLIENT_COMMENTS_GET] TO rl_client_search_r;
GO
