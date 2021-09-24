USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [KGS].[MEMO_CLAIM_DELETE]
	@ID				UNIQUEIDENTIFIER
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

		INSERT INTO KGS.MemoClaim(
						ID_MASTER, TP, DATE, ID_CLIENT, CL_NAME, ID_VENDOR, ID_TRADESITE, DATE_LIMIT, CLAIM_SUM,
						TENDER_DATE, TENDER_NUM, DETAILS, RTRN, RTRN_RULE, CO_BEGIN, CO_END, CO_DISCOUNT, CO_SUM,
						NOTE, STATUS, UPD_DATE, UPD_USER)
			SELECT
				@ID, TP, DATE, ID_CLIENT, CL_NAME, ID_VENDOR, ID_TRADESITE, DATE_LIMIT, CLAIM_SUM, TENDER_DATE, TENDER_NUM,
				DETAILS, RTRN, RTRN_RULE, CO_BEGIN, CO_END, CO_DISCOUNT, CO_SUM, NOTE, 2, UPD_DATE, UPD_USER
			FROM KGS.MemoClaim
			WHERE ID = @ID

		UPDATE KGS.MemoClaim
		SET STATUS			=	3,
			UPD_DATE		=	GETDATE(),
			UPD_USER		=	ORIGINAL_LOGIN()
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
GRANT EXECUTE ON [KGS].[MEMO_CLAIM_DELETE] TO rl_kgs_claim;
GO
