USE [DBF_NAH]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[dbo].[CLIENT_DOCUMENT_SETTINGS_ADD]', 'P ') IS NULL EXEC('CREATE PROCEDURE [dbo].[CLIENT_DOCUMENT_SETTINGS_ADD]  AS SELECT 1')
GO
/*
Автор:
Дата создания:  
Описание:
*/

ALTER PROCEDURE [dbo].[CLIENT_DOCUMENT_SETTINGS_ADD]
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

		INSERT INTO dbo.ClientDocumentSettingsTable
				(
					CDS_ID_CLIENT, CDS_ACT_CONTRACT,
					CDS_ACT_POS, CDS_ACT_POS_F, CDS_ACT_NAME, CDS_ACT_NAME_F,
					CDS_BILL_REST, CDS_INS_CONTRACT, CDS_INS_NAME
				)
		VALUES
				(
					@clientid, @actcontract, @actpos, @actposf, @actname,
					@actnamef, @billrest, @inscontract, @insname
				)

		SELECT SCOPE_IDENTITY() AS NEW_IDEN

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END

GO
GRANT EXECUTE ON [dbo].[CLIENT_DOCUMENT_SETTINGS_ADD] TO rl_client_w;
GO
