USE [ClientDB]
	GO
	SET ANSI_NULLS ON
	GO
	SET QUOTED_IDENTIFIER ON
	GO
	
CREATE PROCEDURE [dbo].[GET_COMPLECT_CLIENT]
@COMPLECTNAME varchar(50),
@ClientShortName varchar(100) OUTPUT,
@ClientFullName varchar(250) OUTPUT
--WITH EXECUTE AS OWNER
AS
BEGIN  
		EXECUTE AS USER = 'CLAIM_VIEW'
		SELECT TOP 1
			   @ClientShortName = C.ClientShortName, @ClientFullName = C.[ClientFullName]
		  FROM [ClientDB].[USR].[USRActiveView] U 
		  INNER JOIN [ClientDB].[dbo].ClientTable C ON C.ClientID = U.[UD_ID_CLIENT]
		  INNER JOIN dbo.SystemTable s ON s.SystemID = u.UF_ID_SYSTEM
		where dbo.DistrString(s.SystemShortName, U.UD_DISTR, U.UD_COMP) = @COMPLECTNAME

		REVERT
	SET NOCOUNT OFF
END