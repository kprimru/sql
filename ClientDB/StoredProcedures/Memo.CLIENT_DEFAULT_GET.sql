USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[Memo].[CLIENT_DEFAULT_GET]', 'P ') IS NULL EXEC('CREATE PROCEDURE [Memo].[CLIENT_DEFAULT_GET]  AS SELECT 1')
GO
ALTER PROCEDURE [Memo].[CLIENT_DEFAULT_GET]
	@ID	INT
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

		SELECT TOP 1 PayTypeID, ContractPayID
		FROM
			dbo.ClientTable a
			INNER JOIN dbo.ContractTable b ON a.ClientID = b.CLientID
		WHERE a.CLientID = @ID
		ORDER BY ContractBegin DESC, ContractID DESC

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [Memo].[CLIENT_DEFAULT_GET] TO rl_client_memo_r;
GO
