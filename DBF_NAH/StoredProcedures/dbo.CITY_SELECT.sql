USE [DBF_NAH]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[dbo].[CITY_SELECT]', 'P ') IS NULL EXEC('CREATE PROCEDURE [dbo].[CITY_SELECT]  AS SELECT 1')
GO

/*
Автор:		  Денисов Алексей
Описание:
*/

ALTER PROCEDURE [dbo].[CITY_SELECT]
	@active bit = NULL
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

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END

GO
GRANT EXECUTE ON [dbo].[CITY_SELECT] TO rl_city_r;
GO
