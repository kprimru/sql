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
ALTER PROCEDURE [dbo].[BILL_SET_ORG]
	@billid INT,
	@orgid SMALLINT
AS
BEGIN
	SET NOCOUNT ON;

	UPDATE dbo.BillTable
	SET BL_ID_ORG = @orgid
	WHERE BL_ID = @billid
END
GO
GRANT EXECUTE ON [dbo].[BILL_SET_ORG] TO rl_bill_w;
GO