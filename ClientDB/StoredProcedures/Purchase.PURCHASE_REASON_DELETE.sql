USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[Purchase].[PURCHASE_REASON_DELETE]', 'P ') IS NULL EXEC('CREATE PROCEDURE [Purchase].[PURCHASE_REASON_DELETE]  AS SELECT 1')
GO
ALTER PROCEDURE [Purchase].[PURCHASE_REASON_DELETE]
	@ID	UNIQUEIDENTIFIER
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

		DELETE
		FROM Purchase.ClientConditionReason
		WHERE CCR_ID_PR = @ID

		DELETE
		FROM Purchase.PurchaseReason
		WHERE PR_ID = @ID

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [Purchase].[PURCHASE_REASON_DELETE] TO rl_reason_d;
GO
