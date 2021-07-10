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

ALTER PROCEDURE [dbo].[CLIENT_ADDRESS_CHECK_TYPE]
  @clientid int,
  @addresstypeid int

AS

BEGIN
	SET NOCOUNT ON

	SELECT CA_ID
	FROM dbo.ClientAddressTable
	WHERE CA_ID_CLIENT = @clientid AND CA_ID_TYPE = @addresstypeid

	SET NOCOUNT OFF
END






GO
GRANT EXECUTE ON [dbo].[CLIENT_ADDRESS_CHECK_TYPE] TO rl_client_address_w;
GRANT EXECUTE ON [dbo].[CLIENT_ADDRESS_CHECK_TYPE] TO rl_client_w;
GO