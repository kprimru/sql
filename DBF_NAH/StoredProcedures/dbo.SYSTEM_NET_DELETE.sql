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

ALTER PROCEDURE [dbo].[SYSTEM_NET_DELETE]
	@systemnetid INT
AS
BEGIN
	SET NOCOUNT ON

	DELETE
	FROM dbo.SystemNetTable
	WHERE SN_ID = @systemnetid

	SET NOCOUNT OFF
END




GO
GRANT EXECUTE ON [dbo].[SYSTEM_NET_DELETE] TO rl_system_net_d;
GO