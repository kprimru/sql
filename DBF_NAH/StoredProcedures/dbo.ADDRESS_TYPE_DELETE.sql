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

ALTER PROCEDURE [dbo].[ADDRESS_TYPE_DELETE]
	@addresstypeid TINYINT
AS
BEGIN
	SET NOCOUNT ON

	DELETE
	FROM dbo.AddressTypeTable
	WHERE AT_ID = @addresstypeid

	SET NOCOUNT OFF
END



GO
GRANT EXECUTE ON [dbo].[ADDRESS_TYPE_DELETE] TO rl_address_type_d;
GO