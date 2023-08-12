USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[Purchase].[PLACEMENT_ORDER_SELECT]', 'P ') IS NULL EXEC('CREATE PROCEDURE [Purchase].[PLACEMENT_ORDER_SELECT]  AS SELECT 1')
GO
CREATE OR ALTER PROCEDURE [Purchase].[PLACEMENT_ORDER_SELECT]
	@FILTER VARCHAR(100) = NULL OUTPUT
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

		SELECT PO_ID, PO_NAME, PO_NUM
		FROM Purchase.PlacementOrder
		WHERE @FILTER IS NULL
			OR PO_NAME LIKE @FILTER
			OR CONVERT(VARCHAR(20), PO_NUM) LIKE @FILTER
		ORDER BY PO_NUM, PO_NAME

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [Purchase].[PLACEMENT_ORDER_SELECT] TO rl_placement_order_r;
GO
