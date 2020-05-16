USE [SaleDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [Client].[OFFICE_2GIS_GET]
	@ID	UNIQUEIDENTIFIER
AS
BEGIN
	SET NOCOUNT ON;

    DECLARE
        @DebugError     VarChar(512),
        @DebugContext   Xml,
        @Params         Xml;

    EXEC [Debug].[Execution@Start]
        @Proc_Id        = @@ProcId,
        @Params         = @Params,
        @DebugContext   = @DebugContext OUT

	SELECT
		'\\bim\common\2gis\!net\grym.exe' AS PROCESS_NAME,
		'"Владивосток" ' + '"!find:map_building" "' + REPLACE(c.NAME, 'пр-кт', '') + '" "' + REPLACE(REPLACE(HOME, 'д. ', ''), 'д.', '') + '" "!select:show" "!select:only" "!show:selection"' AS PROCESS_PARAMS
	FROM
		Client.Office a
		INNER JOIN Client.OfficeAddress b ON a.ID = b.ID_OFFICE
		INNER JOIN Address.Street c ON b.ID_STREET = c.ID
	WHERE a.ID = @ID
END

GO
GRANT EXECUTE ON [Client].[OFFICE_2GIS_GET] TO rl_office_r;
GO