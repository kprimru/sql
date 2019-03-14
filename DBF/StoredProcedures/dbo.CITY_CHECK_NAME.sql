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

CREATE PROCEDURE [dbo].[CITY_CHECK_NAME] 
	@cityname VARCHAR(100),
	@areaid SMALLINT,
	@regionid SMALLINT,
	@countryid SMALLINT
AS
BEGIN
	SET NOCOUNT ON

	SELECT CT_ID 
	FROM dbo.CityTable 
	WHERE CT_NAME = @cityname 
		AND CT_ID_AREA = @areaid 
		AND CT_ID_RG = @regionid 
		AND CT_ID_COUNTRY = @countryid
	SET NOCOUNT OFF
END



