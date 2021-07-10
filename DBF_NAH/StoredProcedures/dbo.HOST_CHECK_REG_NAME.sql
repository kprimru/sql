USE [DBF_NAH]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
Автор:		  Денисов Алексей
Дата создания: 18.11.2008
Описание:	  Возвращает ID хоста с указанным
               названием рег.
*/

ALTER PROCEDURE [dbo].[HOST_CHECK_REG_NAME]
	@hostregname VARCHAR(20)
AS
BEGIN
	SET NOCOUNT ON

	SELECT HST_ID
	FROM dbo.HostTable
	WHERE HST_REG_NAME = @hostregname

	SET NOCOUNT OFF
END
GO
GRANT EXECUTE ON [dbo].[HOST_CHECK_REG_NAME] TO rl_host_w;
GO