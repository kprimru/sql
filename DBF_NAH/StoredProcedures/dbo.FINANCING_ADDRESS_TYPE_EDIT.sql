USE [DBF_NAH]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


/*
Автор:			Денисов Алексей
Дата создания:	3 July 2009
Описание:

*/

ALTER PROCEDURE [dbo].[FINANCING_ADDRESS_TYPE_EDIT]
	@fatid SMALLINT,
	@addrtypeid TINYINT,
	@text VARCHAR(50),
	@active BIT
AS
BEGIN
	SET NOCOUNT ON

	UPDATE dbo.FinancingAddressTypeTable
	SET	FAT_ID_ADDR_TYPE = @addrtypeid,
		FAT_TEXT = @text,
		FAT_ACTIVE = @active

	WHERE FAT_ID = @fatid

	SET NOCOUNT OFF
END




GO
GRANT EXECUTE ON [dbo].[FINANCING_ADDRESS_TYPE_EDIT] TO rl_financing_address_type_w;
GO