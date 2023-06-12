USE [DBF]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[dbo].[ADDRESS_TEMPLATE_GET]', 'P ') IS NULL EXEC('CREATE PROCEDURE [dbo].[ADDRESS_TEMPLATE_GET]  AS SELECT 1')
GO


/*
Автор:			Денисов Алексей
Описание:
Дата:			15.07.2009
*/

ALTER PROCEDURE [dbo].[ADDRESS_TEMPLATE_GET]
	@atlid SMALLINT
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
			ATL_ID, ATL_CAPTION,
			ATL_INDEX, ATL_COUNTRY, ATL_REGION,	ATL_AREA, ATL_CITY_PREFIX, ATL_CITY,
			ATL_STR_PREFIX, ATL_STREET,	ATL_HOME, ATL_ACTIVE
		FROM dbo.AddressTemplateTable
		WHERE ATL_ID = @atlid

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [dbo].[ADDRESS_TEMPLATE_GET] TO rl_address_template_r;
GO
