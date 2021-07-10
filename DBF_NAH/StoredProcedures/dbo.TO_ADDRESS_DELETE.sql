USE [DBF_NAH]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
Автор:		  Денисов Алексей
Описание:	  Выбрать даанные о сотрудниках указанной ТО.
*/

ALTER PROCEDURE [dbo].[TO_ADDRESS_DELETE]
	@toadid INT
AS
BEGIN
	SET NOCOUNT ON

	DELETE
	FROM dbo.TOAddressTable
	WHERE TA_ID = @toadid

	SET NOCOUNT OFF
END





GO
GRANT EXECUTE ON [dbo].[TO_ADDRESS_DELETE] TO rl_client_d;
GO