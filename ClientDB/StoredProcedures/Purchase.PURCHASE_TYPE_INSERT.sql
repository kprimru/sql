USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[Purchase].[PURCHASE_TYPE_INSERT]', 'P ') IS NULL EXEC('CREATE PROCEDURE [Purchase].[PURCHASE_TYPE_INSERT]  AS SELECT 1')
GO
CREATE OR ALTER PROCEDURE [Purchase].[PURCHASE_TYPE_INSERT]
	@NAME	VARCHAR(50),
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

		INSERT INTO Purchase.PurchaseType(PT_NAME)
			OUTPUT inserted.PT_ID INTO @TBL
			VALUES(@NAME)

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
GRANT EXECUTE ON [Purchase].[PURCHASE_TYPE_INSERT] TO rl_purchase_type_i;
GO
