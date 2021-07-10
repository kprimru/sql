USE [DBF_NAH]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
Автор:		  Денисов Алексей
Дата создания: 23.09.2008
Описание:	  Удалить данные о кол-ве станций
               типа сети с указанным ID из справочника
*/

ALTER PROCEDURE [dbo].[SYSTEM_NET_COUNT_DELETE]
	@systemnetcountid SMALLINT
AS
BEGIN
	SET NOCOUNT ON

	DELETE FROM dbo.SystemNetCountTable WHERE SNC_ID = @systemnetcountid

	SET NOCOUNT OFF
END
GO
GRANT EXECUTE ON [dbo].[SYSTEM_NET_COUNT_DELETE] TO rl_system_net_count_d;
GO