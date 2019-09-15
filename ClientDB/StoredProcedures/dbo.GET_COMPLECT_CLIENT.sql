USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[GET_COMPLECT_CLIENT]
	@COMPLECTNAME		VarChar(50),
	@ClientShortName	VarChar(100) OUTPUT,
	@ClientFullName		VarChar(250) OUTPUT
AS
BEGIN  
	SET NOCOUNT ON;
	
	EXECUTE AS USER = 'CLAIM_VIEW';
	
	SELECT TOP 1
		@ClientShortName = C.ClientShortName,
		@ClientFullName = C.[ClientFullName]
	FROM USR.USRActiveView U 
	INNER JOIN dbo.ClientTable C ON C.ClientID = U.UD_ID_CLIENT
	INNER JOIN dbo.SystemTable s ON s.SystemID = u.UF_ID_SYSTEM
	WHERE dbo.DistrString(s.SystemShortName, U.UD_DISTR, U.UD_COMP) = @COMPLECTNAME

	REVERT
END