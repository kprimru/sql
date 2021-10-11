USE [DBF_NAH]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




/*
Автор:			Денисов Алексей
Описание:
Дата:			15-July-2009
*/

ALTER PROCEDURE [dbo].[ADDRESS_TEMPLATE_SELECT]
	@active BIT = NULL
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

		SELECT --ATL_ID, ATL_CAPTION
			ATL_ID,
			ATL_CAPTION,
			ATL_INDEX,
			ATL_COUNTRY,
			ATL_REGION,
			ATL_AREA,
			ATL_CITY_PREFIX,
			ATL_CITY,
			ATL_STR_PREFIX,
			ATL_STREET,
			ATL_HOME
		FROM dbo.AddressTemplateTable
		WHERE ATL_ACTIVE = ISNULL(@active, ATL_ACTIVE)
		ORDER BY ATL_CAPTION

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END

GO
GRANT EXECUTE ON [dbo].[ADDRESS_TEMPLATE_SELECT] TO rl_address_template_r;
GO
