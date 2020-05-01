USE [DBF]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[PRICE_SYSTEM_TYPE_SELECT]
	@ACTIVE	BIT = 1
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
			SYS_SHORT_NAME, 
			PT_NAME, 
			SST_CAPTION, 
			CASE 
				WHEN PST_COEF IS NOT NULL THEN 'Коэф: ' + CONVERT(VARCHAR(20), PST_COEF)
				WHEN PST_FIXED IS NOT NULL THEN 'Фикс. ст-ть:' + CONVERT(VARCHAR(20), PST_FIXED)
				WHEN PST_DISCOUNT IS NOT NULL THEN 'Скидка: ' + CONVERT(VARCHAR(20), PST_DISCOUNT) + '%'
				ELSE 'Что это???'
			END AS PST_STRING,
			PST_START, PST_END
		FROM 
			dbo.PriceSystemType
			INNER JOIN dbo.SystemTable ON SYS_ID = PST_ID_SYSTEM
			INNER JOIN dbo.PriceTypeTable ON PT_ID = PST_ID_PRICE
			INNER JOIN dbo.SystemTypeTable ON SST_ID = PST_ID_TYPE
		WHERE PST_ACTIVE = ISNULL(@ACTIVE, PST_ACTIVE)
		ORDER BY SYS_ORDER, PST_START
		
		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();
		
		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;
		
		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GRANT EXECUTE ON [dbo].[PRICE_SYSTEM_TYPE_SELECT] TO rl_price_system_type_r;
GO