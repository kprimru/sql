USE [DBF_NAH]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
Автор:		  Денисов Алексей
Описание:
*/

ALTER PROCEDURE [dbo].[CONTRACT_TYPE_ADD]
	@contracttypename VARCHAR(100),
	@active BIT = 1,
	@oldcode INT = NULL,
	@returnvalue BIT = 1
AS
BEGIN
	SET NOCOUNT ON

	INSERT INTO dbo.ContractTypeTable(CTT_NAME, CTT_ACTIVE, CTT_OLD_CODE)
	VALUES (@contracttypename, @active, @oldcode)

	IF @returnvalue = 1
		SELECT SCOPE_IDENTITY() AS NEW_IDEN

	SET NOCOUNT OFF
END





GO
GRANT EXECUTE ON [dbo].[CONTRACT_TYPE_ADD] TO rl_contract_type_w;
GO