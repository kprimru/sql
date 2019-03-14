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

CREATE PROCEDURE [dbo].[CITY_GET]  
  @cityid int = NULL
AS

BEGIN
	SET NOCOUNT ON

	SELECT 
			ct.CT_ID, ct.CT_NAME, ct.CT_PREFIX, ct.CT_PHONE, RG_NAME, ct.CT_REGION,
			RG_ID, AR_NAME, AR_ID, CNT_NAME, CNT_ID, ct.CT_ACTIVE,
			z.CT_ID AS CTB_ID, z.CT_NAME AS CTB_NAME
	FROM 
		dbo.CityTable ct LEFT OUTER JOIN
		dbo.RegionTable rt ON rt.RG_ID = ct.CT_ID_RG LEFT OUTER JOIN
		dbo.AreaTable art ON art.AR_ID = ct.CT_ID_AREA LEFT OUTER JOIN
		dbo.CountryTable cnt ON cnt.CNT_ID = ct.CT_ID_COUNTRY LEFT OUTER JOIN
		dbo.CityTable z ON z.CT_ID = ct.CT_ID_BASE
	WHERE ct.CT_ID = @cityid  

	SET NOCOUNT OFF
END






