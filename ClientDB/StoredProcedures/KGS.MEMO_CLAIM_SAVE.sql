USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [KGS].[MEMO_CLAIM_SAVE]
	@ID				UNIQUEIDENTIFIER OUTPUT,
	@TP				TINYINT,
	@ID_CLIENT		INT,
	@CL_NAME		NVARCHAR(256),
	@ID_VENDOR		UNIQUEIDENTIFIER,
	@ID_TRADESITE	UNIQUEIDENTIFIER,
	@DATE_LIMIT		SMALLDATETIME,
	@CLAIM_SUM		MONEY,
	@TENDER_DATE	SMALLDATETIME,
	@TENDER_NUM		NVARCHAR(128),
	@DETAILS		NVARCHAR(MAX),
	@RTRN			BIT,
	@RTRN_RULE		NVARCHAR(64),
	@CO_BEGIN		SMALLDATETIME,
	@CO_END			SMALLDATETIME,
	@CO_DISCOUNT	DECIMAL(8, 2),
	@CO_SUM			MONEY,
	@NOTE			NVARCHAR(MAX)
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

		IF @ID IS NULL
		BEGIN
			DECLARE @TBL TABLE(ID UNIQUEIDENTIFIER)

			INSERT INTO KGS.MemoClaim(
							TP, DATE, ID_CLIENT, CL_NAME, ID_VENDOR, ID_TRADESITE, DATE_LIMIT, CLAIM_SUM, TENDER_DATE, TENDER_NUM,
							DETAILS, RTRN, RTRN_RULE, CO_BEGIN, CO_END, CO_DISCOUNT, CO_SUM, NOTE)
				OUTPUT inserted.ID INTO @TBL
				SELECT
					@TP, dbo.DateOf(GETDATE()), @ID_CLIENT, @CL_NAME, @ID_VENDOR, @ID_TRADESITE, @DATE_LIMIT, @CLAIM_SUM,
					@TENDER_DATE, @TENDER_NUM, @DETAILS, @RTRN, @RTRN_RULE, @CO_BEGIN, @CO_END, @CO_DISCOUNT, @CO_SUM, @NOTE

			SELECT @ID = ID FROM @TBL
		END
		ELSE
		BEGIN
			INSERT INTO KGS.MemoClaim(
					ID_MASTER, TP, DATE, ID_CLIENT, CL_NAME, ID_VENDOR, ID_TRADESITE, DATE_LIMIT, CLAIM_SUM, TENDER_DATE, TENDER_NUM,
					DETAILS, RTRN, RTRN_RULE, CO_BEGIN, CO_END, CO_DISCOUNT, CO_SUM, NOTE, STATUS, UPD_DATE, UPD_USER)
				SELECT
					@ID, TP, DATE, ID_CLIENT, CL_NAME, ID_VENDOR, ID_TRADESITE, DATE_LIMIT, CLAIM_SUM, TENDER_DATE, TENDER_NUM,
					DETAILS, RTRN, RTRN_RULE, CO_BEGIN, CO_END, CO_DISCOUNT, CO_SUM, NOTE, 2, UPD_DATE, UPD_USER
				FROM KGS.MemoClaim
				WHERE ID = @ID

			UPDATE KGS.MemoClaim
			SET ID_CLIENT		=	@ID_CLIENT,
				CL_NAME			=	@CL_NAME,
				ID_VENDOR		=	@ID_VENDOR,
				ID_TRADESITE	=	@ID_TRADESITE,
				DATE_LIMIT		=	@DATE_LIMIT,
				CLAIM_SUM		=	@CLAIM_SUM,
				TENDER_DATE		=	@TENDER_DATE,
				TENDER_NUM		=	@TENDER_NUM,
				DETAILS			=	@DETAILS,
				RTRN			=	@RTRN,
				RTRN_RULE		=	@RTRN_RULE,
				CO_BEGIN		=	@CO_BEGIN,
				CO_END			=	@CO_END,
				CO_DISCOUNT		=	@CO_DISCOUNT,
				CO_SUM			=	@CO_SUM,
				NOTE			=	@NOTE,
				UPD_DATE		=	GETDATE(),
				UPD_USER		=	ORIGINAL_LOGIN()
			WHERE ID = @ID
		END

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [KGS].[MEMO_CLAIM_SAVE] TO rl_kgs_claim;
GO