USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[Purchase].[PURCHASE_KIND_UPDATE]', 'P ') IS NULL EXEC('CREATE PROCEDURE [Purchase].[PURCHASE_KIND_UPDATE]  AS SELECT 1')
GO
CREATE OR ALTER PROCEDURE [Purchase].[PURCHASE_KIND_UPDATE]
	@ID		UNIQUEIDENTIFIER,
	@NAME	VARCHAR(100)
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

		UPDATE Purchase.PurchaseKind
		SET PK_NAME = @NAME
		WHERE PK_ID = @ID

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [Purchase].[PURCHASE_KIND_UPDATE] TO rl_purchase_kind_u;
GO
