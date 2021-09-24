USE [DBF]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [Price].[PRICE_SYSTEM_NET_LIST_SELECT]
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
			PT_ID, PT_SHORT, SST_ID, SST_CAPTION, NT_ID, NT_SHORT,
			(
				SELECT INDEXING
				FROM Price.PriceSettings
				WHERE ID_PRICE = PT_ID
					AND ID_SYS_TYPE = SST_ID
					AND ID_NET_TYPE = NT_ID
			) AS INDEXING
		FROM
			Price.PriceType
			CROSS JOIN dbo.SystemTypeTable
			CROSS JOIN dbo.NetType
		ORDER BY PT_ORDER, SST_ORDER, NT_NET, NT_TECH

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [Price].[PRICE_SYSTEM_NET_LIST_SELECT] TO rl_price_w;
GO
