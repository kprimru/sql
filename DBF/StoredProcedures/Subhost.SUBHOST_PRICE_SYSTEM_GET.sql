USE [DBF]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [Subhost].[SUBHOST_PRICE_SYSTEM_GET]
	@SPS_ID	INT
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
			SPS_ID,
			SYS_ID, SYS_SHORT_NAME,
			PR_ID, PR_DATE,
			PT_ID, PT_NAME,
			SH_ID, SH_SHORT_NAME,
			SPS_PRICE
		FROM
			Subhost.SubhostPriceSystemTable INNER JOIN
			dbo.SystemTable ON SPS_ID_SYSTEM = SYS_ID INNER JOIN
			dbo.PriceTypeTable ON SPS_ID_TYPE = PT_ID INNER JOIN
			dbo.SubhostTable ON SPS_ID_HOST = SH_ID INNER JOIN
			dbo.PeriodTable ON SPS_ID_PERIOD = PR_ID
		WHERE SPS_ID = @SPS_ID

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
