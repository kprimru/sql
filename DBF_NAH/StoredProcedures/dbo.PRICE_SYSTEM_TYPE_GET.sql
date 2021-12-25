USE [DBF_NAH]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[PRICE_SYSTEM_TYPE_GET]
	@ID	INT
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
			PST_ID,
			SYS_ID, SYS_SHORT_NAME,
			PT_ID, PT_NAME,
			SST_ID, SST_CAPTION,
			PST_COEF, PST_FIXED, PST_DISCOUNT,
			PST_START, PST_END,
			PST_ACTIVE
		FROM
			dbo.PriceSystemType
			INNER JOIN dbo.SystemTable ON SYS_ID = PST_ID_SYSTEM
			INNER JOIN dbo.PriceTypeTable ON PT_ID = PST_ID_PRICE
			INNER JOIN dbo.SystemTypeTable ON SST_ID = PST_ID_TYPE
		WHERE PST_ID = @ID

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END

GO
GRANT EXECUTE ON [dbo].[PRICE_SYSTEM_TYPE_GET] TO rl_price_system_type_r;
GO
