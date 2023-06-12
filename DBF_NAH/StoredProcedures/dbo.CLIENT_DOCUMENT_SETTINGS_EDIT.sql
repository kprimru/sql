USE [DBF_NAH]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[dbo].[CLIENT_DOCUMENT_SETTINGS_EDIT]', 'P ') IS NULL EXEC('CREATE PROCEDURE [dbo].[CLIENT_DOCUMENT_SETTINGS_EDIT]  AS SELECT 1')
GO
/*
Автор:
Дата создания:  
Описание:
*/

ALTER PROCEDURE [dbo].[CLIENT_DOCUMENT_SETTINGS_EDIT]
	@cdsid INT,
	@clientid INT,
	@actcontract VARCHAR(100),
	@actpos VARCHAR(200),
	@actposf VARCHAR(200),
	@actname VARCHAR(500),
	@actnamef VARCHAR(500),
	@billrest BIT,
	@inscontract BIT,
	@insname VARCHAR(500)
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

		UPDATE dbo.ClientDocumentSettingsTable
		SET	CDS_ID_CLIENT = @clientid,
			CDS_ACT_CONTRACT = @actcontract,
			CDS_ACT_POS = @actpos,
			CDS_ACT_POS_F = @actposf,
			CDS_ACT_NAME = @actname,
			CDS_ACT_NAME_F = @actnamef,
			CDS_BILL_REST = @billrest,
			CDS_INS_CONTRACT = @inscontract,
			CDS_INS_NAME = @insname
		WHERE CDS_ID = @cdsid

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END

GO
GRANT EXECUTE ON [dbo].[CLIENT_DOCUMENT_SETTINGS_EDIT] TO rl_client_w;
GO
