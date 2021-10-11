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

ALTER PROCEDURE [dbo].[CONSIGNMENT_DELIVERY]
	@csgid INT,
	@clientid INT
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

		UPDATE dbo.ConsignmentTable
		SET CSG_ID_CLIENT = @clientid,
			CSG_ID_PAYER = (SELECT ISNULL(CL_ID_PAYER, CL_ID) FROM dbo.ClientTable WHERE CL_ID = @clientid)
		WHERE CSG_ID = @csgid

		UPDATE dbo.InvoiceSaleTable
		SET INS_ID_CLIENT = @clientid,
			INS_ID_PAYER = (SELECT ISNULL(CL_ID_PAYER, CL_ID) FROM dbo.ClientTable WHERE CL_ID = @clientid)
		WHERE INS_ID =
			(
				SELECT CSG_ID_INVOICE
				FROM dbo.ConsignmentTable
				WHERE CSG_ID = @csgid
			)

		UPDATE dbo.SaldoTable
		SET SL_ID_CLIENT = @clientid
		WHERE SL_ID_CONSIG_DIS IN
			(
				SELECT CSD_ID
				FROM dbo.ConsignmentDetailTable
				WHERE CSD_ID_CONS = @csgid
			)

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [dbo].[CONSIGNMENT_DELIVERY] TO rl_consignment_w;
GO
