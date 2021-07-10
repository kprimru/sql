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

ALTER PROCEDURE [dbo].[ADDRESS_TYPE_CHECK_NAME]
	@addresstypename VARCHAR(100)
AS
BEGIN
	SET NOCOUNT ON

	SELECT AT_ID
	FROM dbo.AddressTypeTable
	WHERE AT_NAME = @addresstypename

	SET NOCOUNT OFF
END







GO
GRANT EXECUTE ON [dbo].[ADDRESS_TYPE_CHECK_NAME] TO rl_address_type_w;
GO