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

ALTER PROCEDURE [dbo].[BILL_CREATE_DEFAULT_GET]
AS
BEGIN
	SET NOCOUNT ON;

	SELECT SO_ID, SO_NAME
	FROM dbo.SaleObjectTable
	WHERE SO_ID = 1
END


GO
GRANT EXECUTE ON [dbo].[BILL_CREATE_DEFAULT_GET] TO rl_bill_w;
GO