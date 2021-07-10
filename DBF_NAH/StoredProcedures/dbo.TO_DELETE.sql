USE [DBF_NAH]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
Автор:			Денисов Алексей
Описание:		Выбор всех точек обслуживания указанного клиента
*/

ALTER PROCEDURE [dbo].[TO_DELETE]
	@toid INT
AS
BEGIN
	SET NOCOUNT ON;

	DELETE FROM dbo.TOAddressTable WHERE TA_ID_TO = @toid
	DELETE FROM dbo.TOTable WHERE TO_ID = @toid

	SET NOCOUNT OFF
END
GO
GRANT EXECUTE ON [dbo].[TO_DELETE] TO rl_client_d;
GRANT EXECUTE ON [dbo].[TO_DELETE] TO rl_to_d;
GO