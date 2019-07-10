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

CREATE PROCEDURE [dbo].[CITY_SELECT]  
	@active bit = NULL
AS

BEGIN
	SET NOCOUNT ON


	SELECT 
			CT_ID, CT_NAME, CT_PREFIX, RG_NAME, RG_ID, 
			AR_NAME, AR_ID, CNT_NAME, CNT_ID
	FROM 
		dbo.CityTable ct LEFT OUTER JOIN
		dbo.RegionTable rt ON rt.RG_ID = CT_ID_RG LEFT OUTER JOIN
		dbo.AreaTable art ON art.AR_ID = CT_ID_AREA LEFT OUTER JOIN
		dbo.CountryTable cnt ON cnt.CNT_ID = ct.CT_ID_COUNTRY
	WHERE CT_ACTIVE = ISNULL(@active, CT_ACTIVE)
	ORDER BY CT_NAME, RG_NAME, AR_NAME, CNT_NAME

	SET NOCOUNT OFF
END




