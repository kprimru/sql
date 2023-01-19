﻿USE [DBF_NAH]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[dbo].[SUBHOST_CITY_GET]', 'P ') IS NULL EXEC('CREATE PROCEDURE [dbo].[SUBHOST_CITY_GET]  AS SELECT 1')
GO

/*
Автор:		  Денисов Алексей
Описание:
*/

ALTER PROCEDURE [dbo].[SUBHOST_CITY_GET]
	@subhostcityid INT = NULL
AS
BEGIN
	SET NOCOUNT ON

	DECLARE
		@DebugError		VarChar(512),
		@DebugContext	Xml,
		@Params			Xml;

	EXEC [Debug].[Execution@Start]
		@Proc_Id		= @@ProcId,
		@Params			= @Params,
		@DebugContext	= @DebugContext OUT

	BEGIN TRY

		SELECT SC_ID, SH_SHORT_NAME, SH_ID, CT_NAME, CT_ID, MA_ID, MA_SHORT_NAME, SC_ACTIVE
		FROM
			dbo.SubhostCityTable a INNER JOIN
			dbo.SubhostTable b ON a.SC_ID_SUBHOST = b.SH_ID INNER JOIN
			dbo.CityTable c ON c.CT_ID = a.SC_ID_CITY INNER JOIN
			dbo.MarketAreaTable d ON d.MA_ID = a.SC_ID_MARKET_AREA
		WHERE SC_ID = @subhostcityid

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END

GO
GRANT EXECUTE ON [dbo].[SUBHOST_CITY_GET] TO rl_subhost_city_r;
GO
