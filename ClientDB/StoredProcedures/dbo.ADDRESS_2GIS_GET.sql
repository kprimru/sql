USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[ADDRESS_2GIS_GET]
	@CA_ID	UNIQUEIDENTIFIER
AS
BEGIN
	SET NOCOUNT ON;

	SELECT
		'\\bim\common\2gis\!net\grym.exe' AS PROCESS_NAME,
		'"' + CT_2GIS_MAP + '" ' + '"!find:map_building" "' + CT_2GIS_CITY + '" "' + REPLACE(ST_NAME, '��-��', '') + '" "' + REPLACE(REPLACE(CA_HOME, '�. ', ''), '�.', '') + '" "!select:show" "!select:only" "!show:selection"' AS PROCESS_PARAMS,
		CT_2GIS_MAP, CT_2GIS_CITY, ST_NAME, CA_HOME
	FROM 
		dbo.ClientAddress a
		INNER JOIN dbo.Street b ON a.CA_ID_STREET = b.ST_ID
		INNER JOIN dbo.City c ON b.ST_ID_CITY = c.CT_ID
	WHERE CA_ID = @CA_ID
		AND CT_2GIS_MAP IS NOT NULL
		AND CT_2GIS_CITY IS NOT NULL 
END
