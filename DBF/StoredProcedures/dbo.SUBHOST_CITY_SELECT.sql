USE [DBF]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
Автор:			Денисов Алексей/Богдан Владимир
Дата создания:  
Описание:
*/

ALTER PROCEDURE [dbo].[SUBHOST_CITY_SELECT]
	@active BIT
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

		SELECT SC_ID, SH_SHORT_NAME, SH_ID, CT_NAME, CT_ID, MA_ID, MA_SHORT_NAME
		FROM
			dbo.SubhostCityTable a INNER JOIN
			dbo.SubhostTable b ON a.SC_ID_SUBHOST = b.SH_ID INNER JOIN
			dbo.CityTable c ON c.CT_ID = a.SC_ID_CITY INNER JOIN
			dbo.MarketAreaTable d ON d.MA_ID = a.SC_ID_MARKET_AREA
		WHERE SC_ACTIVE = ISNULL(@active, SC_ACTIVE)
		ORDER BY SH_SHORT_NAME, CT_NAME

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [dbo].[SUBHOST_CITY_SELECT] TO rl_subhost_city_r;
GO
