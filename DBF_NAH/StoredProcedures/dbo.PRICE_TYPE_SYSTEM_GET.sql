USE [DBF_NAH]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[PRICE_TYPE_SYSTEM_GET]
	@PTS_ID	INT
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

		SELECT SST_ID, SST_CAPTION, PT_ID, PT_NAME, PTS_ACTIVE
		FROM
			dbo.PriceTypeSystemTable INNER JOIN
			dbo.PriceTypeTable ON PT_ID = PTS_ID_PT INNER JOIN
			dbo.SystemTypeTable ON SST_ID = PTS_ID_ST
		WHERE PTS_ID = @PTS_ID

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END

GO
GRANT EXECUTE ON [dbo].[PRICE_TYPE_SYSTEM_GET] TO rl_price_type_system_r;
GO
