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

CREATE PROCEDURE [dbo].[CONSIGNMENT_EDIT]
	@csgid INT,
	@csgidorg SMALLINT,
	@csgidclient INT,
	@csgconsignname VARCHAR(250),
	@csgconsignaddress VARCHAR(250),
	@inn VARCHAR(50),
	@kpp VARCHAR(50),
	@csgconsignokpo VARCHAR(250),
	@csgclientname VARCHAR(250),
	@csgclientaddress VARCHAR(250),
	@phone VARCHAR(50),
	@bank VARCHAR(500),
	@csgfound VARCHAR(100),
	@csgnum VARCHAR(50),
	@csgdate SMALLDATETIME
AS
BEGIN
	SET NOCOUNT ON;

	UPDATE dbo.ConsignmentTable 
	SET CSG_ID_ORG = @csgidorg, 
		CSG_ID_CLIENT = @csgidclient, 
		CSG_CONSIGN_NAME = @csgconsignname, 
		CSG_CONSIGN_ADDRESS = @csgconsignaddress,
		CSG_CONSIGN_INN = @inn,
		CSG_CONSIGN_KPP = @kpp,		
		CSG_CONSIGN_OKPO = @csgconsignokpo, 
		CSG_CLIENT_NAME = @csgclientname, 
		CSG_CLIENT_ADDRESS = @csgclientaddress, 
		CSG_CLIENT_PHONE = @phone,
		CSG_CLIENT_BANK = @bank,
		CSG_FOUND = @csgfound,
		CSG_NUM = @csgnum, 
		CSG_DATE = @csgdate
	WHERE CSG_ID = @csgid 

END

