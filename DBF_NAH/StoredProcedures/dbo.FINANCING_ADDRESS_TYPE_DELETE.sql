USE [DBF_NAH]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
Автор:			Денисов Алексей
Дата создания:	3 July 2009
Описание:		Возвращает 0, если тип адреса в фин. документе
				с указанным кодом можно удалить из
				справочника,
				-1 в противном случае
*/

ALTER PROCEDURE [dbo].[FINANCING_ADDRESS_TYPE_DELETE]
	@fatid SMALLINT
AS
BEGIN
	SET NOCOUNT ON

	DELETE FROM dbo.FinancingAddressTypeTable
	WHERE FAT_ID = @fatid

	SET NOCOUNT OFF
END

GO
GRANT EXECUTE ON [dbo].[FINANCING_ADDRESS_TYPE_DELETE] TO rl_financing_address_type_d;
GO