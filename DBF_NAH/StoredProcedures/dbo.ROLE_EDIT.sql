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

ALTER PROCEDURE [dbo].[ROLE_EDIT]
	@roleid INT,
	@rolenote VARCHAR(500)
AS
BEGIN
	SET NOCOUNT ON;

	UPDATE dbo.RoleTable
	SET ROLE_NOTE = @rolenote
	WHERE ROLE_ID = @roleid
END

GO
GRANT EXECUTE ON [dbo].[ROLE_EDIT] TO rl_role_w;
GO