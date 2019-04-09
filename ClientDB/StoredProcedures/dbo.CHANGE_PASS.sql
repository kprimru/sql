USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[CHANGE_PASS]
	@login varchar(50),
    @password varchar(50)
AS
BEGIN	
	SET NOCOUNT ON;

    EXEC('ALTER LOGIN ' + @login + ' WITH PASSWORD = ''' + @password + '''')    
END