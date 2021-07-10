USE [DBF_NAH]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
�����:
���� ��������:  
��������:
*/

ALTER PROCEDURE [dbo].[BILL_DELIVERY]
	@billid INT,
	@clientid INT
AS
BEGIN
	SET NOCOUNT ON;

	UPDATE dbo.BillTable
	SET BL_ID_CLIENT = @clientid,
		BL_ID_PAYER = (SELECT ISNULL(CL_ID_PAYER, CL_ID) FROM dbo.ClientTable WHERE CL_ID = @clientid)
	WHERE BL_ID = @billid

	UPDATE dbo.SaldoTable
	SET SL_ID_CLIENT = @clientid
	WHERE SL_ID_BILL_DIS IN
		(
			SELECT BD_ID
			FROM dbo.BillDistrTable
			WHERE BD_ID_BILL = @billid
		)
END

GO
GRANT EXECUTE ON [dbo].[BILL_DELIVERY] TO rl_bill_w;
GO