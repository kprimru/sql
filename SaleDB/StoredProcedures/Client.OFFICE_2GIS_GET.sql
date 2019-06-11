USE [SaleDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Client].[OFFICE_2GIS_GET]
	@ID	UNIQUEIDENTIFIER
AS
BEGIN
	SET NOCOUNT ON;

	SELECT
		'\\bim\common\2gis\!net\grym.exe' AS PROCESS_NAME,
		'"Владивосток" ' + '"!find:map_building" "' + REPLACE(c.NAME, 'пр-кт', '') + '" "' + REPLACE(REPLACE(HOME, 'д. ', ''), 'д.', '') + '" "!select:show" "!select:only" "!show:selection"' AS PROCESS_PARAMS		
	FROM 
		Client.Office a
		INNER JOIN Client.OfficeAddress b ON a.ID = b.ID_OFFICE
		INNER JOIN Address.Street c ON b.ID_STREET = c.ID		
	WHERE a.ID = @ID
END
