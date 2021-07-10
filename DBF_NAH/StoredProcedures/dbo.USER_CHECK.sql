USE [DBF_NAH]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
�����:
���� ��������:  
��������:
*/

ALTER PROCEDURE [dbo].[USER_CHECK]
	@name VARCHAR(100)
AS
BEGIN
	SET NOCOUNT ON;

	SELECT [NAME] AS [USER_NAME]
	FROM sys.server_principals
	WHERE [NAME] = @name
		AND [TYPE_DESC] = 'SQL_LOGIN'
END

GO
GRANT EXECUTE ON [dbo].[USER_CHECK] TO rl_user;
GO