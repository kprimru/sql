USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[KGS].[MEMO_CLAIM_GET]', 'P ') IS NULL EXEC('CREATE PROCEDURE [KGS].[MEMO_CLAIM_GET]  AS SELECT 1')
GO
ALTER PROCEDURE [KGS].[MEMO_CLAIM_GET]
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

		SELECT
			TP, DATE, ID_CLIENT, CL_NAME, ID_VENDOR, ID_TRADESITE, DATE_LIMIT, CLAIM_SUM,
			TENDER_DATE, TENDER_NUM, DETAILS, RTRN, RTRN_RULE, CO_BEGIN, CO_END, CO_DISCOUNT, CO_SUM, NOTE
		FROM KGS.MemoClaim
		WHERE ID = @ID

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [KGS].[MEMO_CLAIM_GET] TO rl_kgs_claim;
GO
