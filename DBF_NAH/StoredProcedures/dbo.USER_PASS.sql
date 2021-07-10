USE [DBF_NAH]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
Автор:
Дата создания:  
Описание:
*/

ALTER PROCEDURE [dbo].[USER_PASS]
	@username VARCHAR(100),
	@pass VARCHAR(100)
AS
BEGIN
	SET NOCOUNT ON;

	EXEC('ALTER LOGIN ' + @username + ' WITH PASSWORD = ''' + @pass + '''')
END

GO
GRANT EXECUTE ON [dbo].[USER_PASS] TO rl_user;
GO