USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[USER_CHECK]
	@USER   VARCHAR(128),
	@LOGIN   VARCHAR(128),
    @OKUSER INT = 0 OUTPUT,
    @OKLOGIN INT = 0 OUTPUT
WITH EXECUTE AS OWNER    
AS
BEGIN
	SET NOCOUNT ON;

    SET @OKLOGIN=0;
    SET @OKUSER=0;
    IF NOT EXISTS (SELECT * FROM sys.database_principals WHERE name = @USER) SET @OKUSER=1
    IF NOT EXISTS (SELECT * FROM sys.database_principals AS u
	   LEFT OUTER JOIN sys.server_principals AS s ON s.sid = u.sid
	   WHERE (Upper(s.name)=Upper(@LOGIN))) SET @OKLOGIN=1
END