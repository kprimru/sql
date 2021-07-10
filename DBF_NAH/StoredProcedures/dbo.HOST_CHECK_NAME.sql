USE [DBF_NAH]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
Автор:		  Денисов Алексей
Дата создания: 18.11.2008
Описание:	  Возвращает хоста с указанным
                названием.
*/

ALTER PROCEDURE [dbo].[HOST_CHECK_NAME]
	@hostname VARCHAR(20)
AS
BEGIN
	SET NOCOUNT ON

	SELECT HST_ID
	FROM dbo.HostTable
	WHERE HST_NAME = @hostname

	SET NOCOUNT OFF
END
GO
GRANT EXECUTE ON [dbo].[HOST_CHECK_NAME] TO rl_host_w;
GO