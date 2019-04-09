USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[CREATE_USER]
        @login varchar(50),
    @password varchar(50)
AS
BEGIN   
	SET NOCOUNT ON;

    EXEC('CREATE LOGIN ' + @login + ' WITH PASSWORD = ''' + @password + ''', CHECK_POLICY = OFF ')

    EXEC('CREATE USER ' + @login + ' FOR LOGIN ' + @login)
END