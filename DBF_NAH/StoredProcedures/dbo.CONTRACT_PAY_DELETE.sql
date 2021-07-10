USE [DBF_NAH]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
�����:		  ������� �������
��������:
*/

ALTER PROCEDURE [dbo].[CONTRACT_PAY_DELETE]
	@id SMALLINT
AS
BEGIN
	SET NOCOUNT ON

	DELETE FROM dbo.ContractPayTable WHERE COP_ID = @id

	SET NOCOUNT OFF
END
GO
GRANT EXECUTE ON [dbo].[CONTRACT_PAY_DELETE] TO rl_contract_pay_d;
GO