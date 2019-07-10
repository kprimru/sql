USE [DBF]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
Автор:		  Денисов Алексей
Описание:	  
*/

CREATE PROCEDURE [dbo].[CITY_EDIT] 
	@cityid INT,
	@cityname VARCHAR(100),
	@cityprefix VARCHAR(50),
	@phone VARCHAR(20),
	@regionid INT,
	@areaid INT,
	@countryid INT,
	@region TINYINT,
	@active BIT = 1,
	@base SMALLINT
AS

BEGIN
	SET NOCOUNT ON

	UPDATE dbo.CityTable 
	SET CT_NAME = @cityname, 
	    CT_PREFIX = @cityprefix, 
	    CT_PHONE = @phone,
		CT_ID_RG = @regionid, 
		CT_ID_AREA = @areaid,  
		CT_ID_COUNTRY = @countryid,
		CT_REGION = @region,
		CT_ID_BASE = @base,
		CT_ACTIVE = @active
	WHERE CT_ID = @cityid

	SET NOCOUNT OFF
END



