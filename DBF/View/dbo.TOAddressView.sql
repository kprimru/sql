USE [DBF]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[TOAddressView]
AS
	SELECT    
		TA_ID_TO, TA_ID, TA_INDEX, TA_HOME, ST_ID, 
		ST_NAME, ISNULL(CT_NAME, '') + ', ' + ISNULL(ST_NAME, '') AS ST_CITY_NAME
	FROM         
		dbo.TOAddressTable 
		LEFT OUTER JOIN dbo.StreetTable ON ST_ID = TA_ID_STREET
		LEFT OUTER JOIN dbo.CityTable ON ST_ID_CITY = CT_ID
