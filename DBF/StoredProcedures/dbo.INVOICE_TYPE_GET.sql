USE [DBF]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO





/*
Автор:
Дата создания:  
Описание:
*/

ALTER PROCEDURE [dbo].[INVOICE_TYPE_GET]
	@intid SMALLINT
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

		SELECT INT_ID, INT_NAME, INT_PSEDO, INT_SALE, INT_BUY, INT_ACTIVE
		FROM
			dbo.InvoiceTypeTable
		WHERE INT_ID = @intid

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [dbo].[INVOICE_TYPE_GET] TO rl_invoice_type_r;
GO
