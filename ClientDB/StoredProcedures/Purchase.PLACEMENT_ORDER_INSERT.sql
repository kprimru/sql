USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[Purchase].[PLACEMENT_ORDER_INSERT]', 'P ') IS NULL EXEC('CREATE PROCEDURE [Purchase].[PLACEMENT_ORDER_INSERT]  AS SELECT 1')
GO
CREATE OR ALTER PROCEDURE [Purchase].[PLACEMENT_ORDER_INSERT]
	@NAME	VARCHAR(150),
	@NUM	SMALLINT,
	@ID		UNIQUEIDENTIFIER = NULL OUTPUT
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

		DECLARE @TBL TABLE(ID UNIQUEIDENTIFIER)

		INSERT INTO Purchase.PlacementOrder(PO_NAME, PO_NUM)
			OUTPUT inserted.PO_ID INTO @TBL
			VALUES(@NAME, @NUM)

		SELECT @ID = ID
		FROM @TBL

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [Purchase].[PLACEMENT_ORDER_INSERT] TO rl_placement_order_i;
GO
