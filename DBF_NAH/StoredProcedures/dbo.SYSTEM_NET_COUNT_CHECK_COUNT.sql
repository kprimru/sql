USE [DBF_NAH]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
Автор:		  Денисов Алексей
Дата создания: 23.09.2008
Описание:	  Возвращает ID типа сети с указанным
				  кол-вом станций.
*/

ALTER PROCEDURE [dbo].[SYSTEM_NET_COUNT_CHECK_COUNT]
	@netcount INT
AS
BEGIN
	SET NOCOUNT ON

	SELECT SNC_ID
	FROM dbo.SystemNetCountTable
	WHERE SNC_NET_COUNT = @netcount

	SET NOCOUNT OFF
END
GO
GRANT EXECUTE ON [dbo].[SYSTEM_NET_COUNT_CHECK_COUNT] TO rl_system_net_count_w;
GO