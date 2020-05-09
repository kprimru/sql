USE [DBF]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
Автор:		  Денисов Алексей
Описание:
*/

ALTER PROCEDURE [dbo].[CITY_GET]
  @cityid int = NULL
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
				ct.CT_ID, ct.CT_NAME, ct.CT_PREFIX, ct.CT_PHONE, RG_NAME, ct.CT_REGION,
				RG_ID, AR_NAME, AR_ID, CNT_NAME, CNT_ID, ct.CT_ACTIVE,
				z.CT_ID AS CTB_ID, z.CT_NAME AS CTB_NAME
		FROM
			dbo.CityTable ct LEFT OUTER JOIN
			dbo.RegionTable rt ON rt.RG_ID = ct.CT_ID_RG LEFT OUTER JOIN
			dbo.AreaTable art ON art.AR_ID = ct.CT_ID_AREA LEFT OUTER JOIN
			dbo.CountryTable cnt ON cnt.CNT_ID = ct.CT_ID_COUNTRY LEFT OUTER JOIN
			dbo.CityTable z ON z.CT_ID = ct.CT_ID_BASE
		WHERE ct.CT_ID = @cityid

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [dbo].[CITY_GET] TO rl_city_r;
GO