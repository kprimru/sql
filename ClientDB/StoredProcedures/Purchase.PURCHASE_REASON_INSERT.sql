USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[Purchase].[PURCHASE_REASON_INSERT]', 'P ') IS NULL EXEC('CREATE PROCEDURE [Purchase].[PURCHASE_REASON_INSERT]  AS SELECT 1')
GO
CREATE OR ALTER PROCEDURE [Purchase].[PURCHASE_REASON_INSERT]
	@NAME	VARCHAR(4000),
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

		INSERT INTO Purchase.PurchaseReason(PR_NAME, PR_NUM)
			OUTPUT inserted.PR_ID INTO @TBL
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
GRANT EXECUTE ON [Purchase].[PURCHASE_REASON_INSERT] TO rl_reason_i;
GO
