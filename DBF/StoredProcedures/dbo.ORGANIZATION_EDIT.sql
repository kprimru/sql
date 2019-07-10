USE [DBF]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



/*
�����:		  ������� �������
��������:	  
*/

CREATE PROCEDURE [dbo].[ORGANIZATION_EDIT] 
	@id SMALLINT,
	@psedo VARCHAR(50),
	@fullname VARCHAR(250),
	@shortname VARCHAR(50),
	@index VARCHAR(50),
	@streetid INT,
	@home VARCHAR(100),
	@sindex VARCHAR(50),
	@sstreetid INT,
	@shome VARCHAR(100),
	@phone VARCHAR(50),
	@bankid SMALLINT,
	@acc VARCHAR(50),
	@loro VARCHAR(50),
	@bik VARCHAR(50),
	@inn VARCHAR(50),
	@kpp VARCHAR(50),
	@okonh VARCHAR(50),
	@okpo VARCHAR(50),
	@buhfam VARCHAR(50),
	@buhname VARCHAR(50),
	@buhotch VARCHAR(50),
	@dirfam VARCHAR(50),
	@dirname VARCHAR(50),	
	@dirotch VARCHAR(50),
	@active BIT = 1
AS
BEGIN
	SET NOCOUNT ON

	UPDATE dbo.OrganizationTable 
	SET 
		ORG_PSEDO = @psedo,
		ORG_FULL_NAME = @fullname, 
		ORG_SHORT_NAME = @shortname, 
		ORG_INDEX = @index, 
		ORG_ID_STREET = @streetid, 
		ORG_HOME = @home,
		ORG_S_INDEX = @sindex, 
		ORG_S_ID_STREET = @sstreetid, 
		ORG_S_HOME = @shome, 
		ORG_PHONE = @phone, 
		ORG_ID_BANK = @bankid,
		ORG_ACCOUNT = @acc,
		ORG_LORO = @loro, 
		ORG_BIK = @bik, 
		ORG_INN = @inn, 
		ORG_KPP = @kpp, 
		ORG_OKONH = @okonh, 
		ORG_OKPO = @okpo, 
		ORG_BUH_FAM = @buhfam, 
		ORG_BUH_NAME = @buhname, 
		ORG_BUH_OTCH = @buhotch, 
		ORG_DIR_FAM = @dirfam, 
		ORG_DIR_NAME = @dirname,
		ORG_DIR_OTCH = @dirotch, 
		ORG_ACTIVE = @active
	WHERE ORG_ID = @id

	SET NOCOUNT OFF
END




