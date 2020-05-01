USE [DBF]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[PRICE_EXPORT_SELECT]
	@PERIOD	SMALLINT,
	@TYPE	SMALLINT
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

		SELECT SYS_REG_NAME, CONVERT(VARCHAR(20), PR_DATE, 112) AS PR_STR, PS_PRICE
		FROM
			dbo.PriceSystemTable
			INNER JOIN dbo.SystemTable ON PS_ID_SYSTEM = SYS_ID
			INNER JOIN dbo.PeriodTable ON PR_ID = PS_ID_PERIOD
		WHERE PR_ID = @PERIOD AND PS_ID_TYPE = @TYPE AND SYS_REG_NAME IS NOT NULL AND SYS_REG_NAME <> '-' AND SYS_REG_NAME <> '--' AND SYS_ACTIVE = 1

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GRANT EXECUTE ON [dbo].[PRICE_EXPORT_SELECT] TO rl_price_list_w;
GO