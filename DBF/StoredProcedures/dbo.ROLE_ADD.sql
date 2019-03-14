USE [DBF]
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

CREATE PROCEDURE [dbo].[ROLE_ADD]
	@name VARCHAR(100),
	@note VARCHAR(500)
AS
BEGIN
	SET NOCOUNT ON;

	INSERT INTO dbo.RoleTable(ROLE_NAME, ROLE_NOTE)
	VALUES (@name, @note)
END
