USE [DBF_NAH]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [Price].[PRICE_DEPEND_FULL_SELECT]
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
			ID_OLD_PRICE, b.PT_SHORT AS OLD_PRICE, ID_NEW_PRICE, c.PT_SHORT AS NEW_PRICE,
			ID_OLD_SYS_TYPE, d.SST_CAPTION AS OLD_SYS, ID_NEW_SYS_TYPE, e.SST_CAPTION AS NEW_SYS,
			ID_OLD_NET, f.NT_SHORT AS NT_OLD, ID_NEW_NET, g.NT_SHORT AS NT_NEW,
			COEF
		FROM
			Price.PriceDepend a
			INNER JOIN Price.PriceType b ON a.ID_OLD_PRICE = b.PT_ID
			INNER JOIN Price.PriceType c ON a.ID_NEW_PRICE = c.PT_ID
			INNER JOIN dbo.SystemTypeTable d ON a.ID_OLD_SYS_TYPE = d.SST_ID
			INNER JOIN dbo.SystemTypeTable e ON a.ID_NEW_SYS_TYPE = e.SST_ID
			INNER JOIN dbo.NetType f ON a.ID_OLD_NET = f.NT_ID
			INNER JOIN dbo.NetType g ON a.ID_NEW_NET = g.NT_ID
		ORDER BY b.PT_ORDER, c.PT_ORDER, d.SST_ORDER, d.SST_NAME, e.SST_ORDER, e.SST_NAME, f.NT_NET, f.NT_TECH, g.NT_NET, g.NT_TECH

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END

GO
GRANT EXECUTE ON [Price].[PRICE_DEPEND_FULL_SELECT] TO rl_price_w;
GO
