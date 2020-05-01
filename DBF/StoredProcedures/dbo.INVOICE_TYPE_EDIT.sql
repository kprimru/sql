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

ALTER PROCEDURE [dbo].[INVOICE_TYPE_EDIT]
	@id SMALLINT,
	@name VARCHAR(100),
	@psedo VARCHAR(50),
	@sale BIT,
	@buy BIT,
	@active BIT = 1
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

		UPDATE dbo.InvoiceTypeTable
		SET INT_NAME = @name,
			INT_PSEDO = @psedo,
			INT_SALE = @sale,
			INT_BUY = @buy,
			INT_ACTIVE = @active
		WHERE INT_ID = @id

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GRANT EXECUTE ON [dbo].[INVOICE_TYPE_EDIT] TO rl_invoice_type_w;
GO