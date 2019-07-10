USE [DBF]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[ClientAddressView]
AS
SELECT
	a.CA_ID, a.CA_ID_TYPE, a.CA_ID_CLIENT, a.CA_INDEX, a.CA_HOME, a.CA_STR, a.CA_FREE,
	b.AT_NAME, c.ST_NAME, d.CT_NAME, d.CT_ID, b.AT_ID, c.ST_ID,
	c.ST_PREFIX, d.CT_PREFIX, c.ST_SUFFIX
	, CNT_ID, CNT_NAME, RG_ID, RG_NAME, AR_ID, AR_NAME, ATL_ID, ATL_CAPTION
FROM
	dbo.ClientAddressTable	AS a INNER JOIN
    dbo.AddressTypeTable	AS b ON a.CA_ID_TYPE	= b.AT_ID LEFT OUTER JOIN
    dbo.StreetTable			AS c ON a.CA_ID_STREET	= c.ST_ID LEFT OUTER JOIN
    dbo.CityTable			AS d ON c.ST_ID_CITY	= d.CT_ID
	
	LEFT OUTER JOIN
    dbo.AreaTable ON AR_ID = d.CT_ID_AREA LEFT OUTER JOIN
    dbo.RegionTable ON RG_ID = d.CT_ID_RG LEFT OUTER JOIN
    dbo.CountryTable ON CNT_ID = d.CT_ID_COUNTRY LEFT OUTER JOIN
	dbo.AddressTemplateTable ON ATL_ID = CA_ID_TEMPLATE
