USE [DBF]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[INVOICE_SELECT]
	@ACTIVE BIT
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
			INS_ID, CL_PSEDO, INS_NUM, INS_DATE, INT_NAME,
			(
				SELECT SUM(INR_SALL)
				FROM dbo.InvoiceRowTable
				WHERE INR_ID_INVOICE = INS_ID
			) AS INS_SALL
		FROM
			dbo.InvoiceSaleTable a
			INNER JOIN dbo.InvoiceTypeTable ON INT_ID = INS_ID_TYPE
			INNER JOIN dbo.ClientTable ON CL_ID = INS_ID_CLIENT
		WHERE INS_DATE >= DATEADD(YEAR, -2, GETDATE())
		ORDER BY INS_DATE DESC, INS_NUM DESC

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [dbo].[INVOICE_SELECT] TO rl_book_sale_p;
GO