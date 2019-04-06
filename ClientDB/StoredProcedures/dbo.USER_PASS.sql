USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[USER_PASS]
	@LOGIN varchar(128),
    @PASS varchar(50),
    @RESULT INT = 0 OUTPUT
WITH EXECUTE AS OWNER
AS
BEGIN	
	SET NOCOUNT ON;

    EXEC('ALTER LOGIN [' + @LOGIN + '] WITH PASSWORD = ''' + @PASS + '''')    
    SET @RESULT=@@ERROR  
    SET NOCOUNT OFF
END