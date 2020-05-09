USE [DBF]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
Автор:			Денисов Алексей/Богдан Владимир
Описание:
*/

ALTER PROCEDURE [dbo].[CLIENT_INVOICE_GET]
	@invid INT
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

		SELECT
			INS_ID_ORG, ORG_SHORT_NAME, INS_DATE, INS_NUM, INS_NUM_YEAR,
			INS_ID_CLIENT, INS_CLIENT_PSEDO, INS_CLIENT_NAME, INS_CLIENT_ADDR,
			INS_CONSIG_NAME, INS_CONSIG_ADDR, INS_CLIENT_INN, INS_CLIENT_KPP,
			INS_INCOME_DATE, INS_DOC_STRING, INS_STORNO, INS_COMMENT, INT_ID, INT_NAME, INS_IDENT
		FROM
			dbo.InvoiceSaleTable	A		LEFT JOIN
			dbo.OrganizationTable	B	ON	A.INS_ID_ORG=B.ORG_ID LEFT JOIN
			dbo.InvoiceTypeTable ON INT_ID = INS_ID_TYPE
		WHERE INS_ID = @invid

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [dbo].[CLIENT_INVOICE_GET] TO rl_invoice_w;
GO