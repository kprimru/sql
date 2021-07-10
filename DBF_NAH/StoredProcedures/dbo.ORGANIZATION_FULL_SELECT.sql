USE [DBF_NAH]
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

ALTER PROCEDURE [dbo].[ORGANIZATION_FULL_SELECT]
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
			ORG_ID, ORG_FULL_NAME, ORG_SHORT_NAME, 
			ORG_INDEX, a.ST_PREFIX, a.ST_NAME, a.CT_PREFIX, a.CT_NAME, ORG_HOME,
			(ORG_INDEX + ', ' + a.CT_PREFIX + a.CT_NAME + ', ' + a.ST_PREFIX + a.ST_NAME + ',' + ORG_HOME) AS ORG_ADDRESS,
			ORG_S_INDEX, b.ST_PREFIX AS ST_S_PREFIX, b.ST_NAME AS ST_S_NAME,
			b.CT_PREFIX AS CT_S_PREFIX, b.CT_NAME AS CT_S_NAME, ORG_S_HOME,
			ORG_PHONE,
			ORG_ACCOUNT, ORG_LORO, ORG_BIK, ORG_INN, ORG_KPP, ORG_OKONH, ORG_OKPO,
			ORG_BUH_FAM, ORG_BUH_NAME, ORG_BUH_OTCH,
			(ORG_BUH_FAM + ' ' + LEFT(ORG_BUH_NAME, 1) + '.' + LEFT(ORG_BUH_OTCH, 1) + '.') AS ORG_BUH_SHORT,
			ORG_DIR_FAM, ORG_DIR_NAME, ORG_DIR_OTCH,
			BA_NAME,
			c.CT_NAME AS BA_CITY
		FROM
			dbo.OrganizationTable LEFT OUTER JOIN
			dbo.AddressView a ON a.ST_ID = ORG_ID_STREET LEFT OUTER JOIN
			dbo.AddressView b ON b.ST_ID = ORG_S_ID_STREET LEFT OUTER JOIN
			dbo.BankTable ON BA_ID = ORG_ID_BANK LEFT OUTER JOIN
			dbo.CityTable c ON c.CT_ID = BA_ID_CITY

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END

GO
GRANT EXECUTE ON [dbo].[ORGANIZATION_FULL_SELECT] TO rl_organization_r;
GO