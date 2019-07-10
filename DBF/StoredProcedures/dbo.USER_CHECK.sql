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

CREATE PROCEDURE [dbo].[USER_CHECK]
	@name VARCHAR(100)
AS
BEGIN
	SET NOCOUNT ON;

	SELECT [NAME] AS [USER_NAME] 
	FROM sys.server_principals 
	WHERE [NAME] = @name
		AND [TYPE_DESC] = 'SQL_LOGIN'		
END
