USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[dbo].[ADDRESS_2GIS_GET]', 'P ') IS NULL EXEC('CREATE PROCEDURE [dbo].[ADDRESS_2GIS_GET]  AS SELECT 1')
GO
ALTER PROCEDURE [dbo].[ADDRESS_2GIS_GET]
	@CA_ID	UNIQUEIDENTIFIER
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE
		@DebugError		VarChar(512),
		@DebugContext	Xml,
		@Params			Xml;

	EXEC [Debug].[Execution@Start]
		@Proc_Id		= @@ProcId,
		@Params			= @Params,
		@DebugContext	= @DebugContext OUT

	BEGIN TRY

		SELECT
			'\\bim\common\2gis\!net\grym.exe' AS PROCESS_NAME,
			'"' + CT_2GIS_MAP + '" ' + '"!find:map_building" "' + CT_2GIS_CITY + '" "' + REPLACE(ST_NAME, 'пр-кт', '') + '" "' + REPLACE(REPLACE(CA_HOME, 'д. ', ''), 'д.', '') + '" "!select:show" "!select:only" "!show:selection"' AS PROCESS_PARAMS,
			CT_2GIS_MAP, CT_2GIS_CITY, ST_NAME, CA_HOME
		FROM
			dbo.ClientAddress a
			INNER JOIN dbo.Street b ON a.CA_ID_STREET = b.ST_ID
			INNER JOIN dbo.City c ON b.ST_ID_CITY = c.CT_ID
		WHERE CA_ID = @CA_ID
			AND CT_2GIS_MAP IS NOT NULL
			AND CT_2GIS_CITY IS NOT NULL

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [dbo].[ADDRESS_2GIS_GET] TO rl_client_card;
GRANT EXECUTE ON [dbo].[ADDRESS_2GIS_GET] TO rl_client_card_r;
GO
