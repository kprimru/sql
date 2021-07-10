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

ALTER PROCEDURE [dbo].[ADDRESS_TYPE_ADD]
	@addresstypename VARCHAR(100),
	@active BIT = 1,
	@returnvalue BIT = 1
AS
BEGIN
	SET NOCOUNT ON

	INSERT INTO dbo.AddressTypeTable (AT_NAME, AT_ACTIVE)
	VALUES (@addresstypename, @active)

	IF @returnvalue = 1
		SELECT SCOPE_IDENTITY() AS NEW_IDEN

	SET NOCOUNT OFF
END







GO
GRANT EXECUTE ON [dbo].[ADDRESS_TYPE_ADD] TO rl_address_type_w;
GO