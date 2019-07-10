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

CREATE PROCEDURE [dbo].[USER_DELETE]
	@username VARCHAR(100)
AS
BEGIN
	SET NOCOUNT ON;

	EXEC('DROP USER [' + @username + ']')
	--EXEC('DROP LOGIN [' + @username + ']')
END

