﻿USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[Purchase].[CLAIM_CANCEL_REASON_DELETE]', 'P ') IS NULL EXEC('CREATE PROCEDURE [Purchase].[CLAIM_CANCEL_REASON_DELETE]  AS SELECT 1')
GO
CREATE OR ALTER PROCEDURE [Purchase].[CLAIM_CANCEL_REASON_DELETE]
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
		FROM Purchase.ClaimCancelReason
		WHERE CCR_ID = @ID

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [Purchase].[CLAIM_CANCEL_REASON_DELETE] TO rl_claim_cancel_reason_d;
GO
