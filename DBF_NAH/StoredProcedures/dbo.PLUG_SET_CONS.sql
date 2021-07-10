USE [DBF_NAH]
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

ALTER PROCEDURE [dbo].[PLUG_SET_CONS]
	@consid INT
AS
BEGIN
	SET NOCOUNT ON;

	UPDATE dbo.ConsignmentTable
	SET CSG_ID_INVOICE =
		(
			SELECT INS_ID
			FROM dbo.InvoiceSaleTable
			WHERE INS_NUM = '0'
				AND INS_NUM_YEAR = '0'
		)
	WHERE CSG_ID = @consid
END

GO
GRANT EXECUTE ON [dbo].[PLUG_SET_CONS] TO rl_invoice_w;
GO