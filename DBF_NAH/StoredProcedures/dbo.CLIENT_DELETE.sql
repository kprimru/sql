USE [DBF_NAH]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
Автор:		  Денисов Алексей
Описание:
*/
ALTER PROCEDURE [dbo].[CLIENT_DELETE]
	@clientid INT
AS
BEGIN
	SET NOCOUNT ON

	DECLARE
		@DebugError		VarChar(512),
		@DebugContext	Xml,
		@Params			Xml;

	EXEC [Debug].[Execution@Start]
		@Proc_Id		= @@ProcId,
		@Params			= @Params,
		@DebugContext	= @DebugContext OUT

	BEGIN TRY

		DELETE
		FROM dbo.ClientFinancing
		WHERE ID_CLIENT = @clientid

		DELETE
		FROM dbo.DistrDeliveryHistoryTable
		WHERE DDH_ID_OLD_CLIENT = @clientid OR DDH_ID_NEW_CLIENT = @clientid

		DELETE
		FROM dbo.ClientDocumentSettingsTable
		WHERE CDS_ID_CLIENT = @clientid

		DELETE
		FROM dbo.ClientFinancingAddressTable
		WHERE CFA_ID_CLIENT = @clientid

		DELETE
		FROM dbo.ClientTable
		WHERE CL_ID = @clientid

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END

GO
GRANT EXECUTE ON [dbo].[CLIENT_DELETE] TO rl_client_d;
GO