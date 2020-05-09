USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [Tender].[PLACEMENT_SAVE]
	@TENDER				UNIQUEIDENTIFIER,
	@SUBJECT			NVARCHAR(256),
	@ID_TYPE			UNIQUEIDENTIFIER,
	@NOTICE_NUM			NVARCHAR(128),
	@DATE				SMALLDATETIME,
	@GK_SUM				MONEY,
	@ID_TRADESITE		UNIQUEIDENTIFIER,
	@URL				NVARCHAR(256),
	@GK_START			SMALLDATETIME,
	@GK_FINISH			SMALLDATETIME,
	@GK_MONTH			SMALLINT,
	@ACTUAL_START		SMALLDATETIME,
	@ACTUAL_FINISH		SMALLDATETIME,
	@ACTUAL_MONTH		SMALLINT,
	@CLAIM_START		SMALLDATETIME,
	@CLAIM_FINISH		SMALLDATETIME,
	@OPENING			SMALLDATETIME,
	@REVIEW				SMALLDATETIME,
	@AUCTION			SMALLDATETIME,
	@CLAIM_PRIVISION	MONEY,
	@GK_PROVISION_PRC	SMALLINT,
	@GK_PROVISION_SUM	MONEY,
	@GK_PROVISION_TAX	UNIQUEIDENTIFIER,
	@EDO_SUM			MONEY,
	@EDO_TAX			UNIQUEIDENTIFIER,
	@ID_VENDOR			UNIQUEIDENTIFIER,
	@PROTOCOL			SMALLDATETIME,
	@AGREE				SMALLDATETIME,
	@GK_DIRECTION		SMALLDATETIME,
	@GK_SIGN			SMALLDATETIME,
	@GK_SIGN_FACT		SMALLDATETIME,
	@GK_NUM				NVARCHAR(128),
	@GK_DATE			SMALLDATETIME,
	@GK_DOP_NUM			NVARCHAR(128),
	@GK_DOP_DATE		SMALLDATETIME,
	@PROVISION_RETURN	SMALLDATETIME,
	@TOTAL				SMALLDATETIME,
	@PART_SUM			MONEY,
	@TARIFF_SUM			MONEY,
	@ECP_SUM			MONEY,
	@INVOICE_NUM		NVARCHAR(20),
	@INVOICE_DATE		DATETIME
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

		UPDATE Tender.Placement
		SET	SUBJECT				=	@SUBJECT,
			ID_TYPE				=	@ID_TYPE,
			NOTICE_NUM			=	@NOTICE_NUM,
			DATE				=	@DATE,
			GK_SUM				=	@GK_SUM,
			ID_TRADESITE		=	@ID_TRADESITE,
			URL					=	@URL,
			GK_START			=	@GK_START,
			GK_FINISH			=	@GK_FINISH,
			GK_MONTH			=	@GK_MONTH,
			ACTUAL_START		=	@ACTUAL_START,
			ACTUAL_FINISH		=	@ACTUAL_FINISH,
			ACTUAL_MONTH		=	@ACTUAL_MONTH,
			CLAIM_START			=	@CLAIM_START,
			CLAIM_FINISH		=	@CLAIM_FINISH,
			OPENING				=	@OPENING,
			REVIEW				=	@REVIEW,
			AUCTION				=	@AUCTION,
			CLAIM_PRIVISION		=	@CLAIM_PRIVISION,
			GK_PROVISION_PRC	=	@GK_PROVISION_PRC,
			GK_PROVISION_SUM	=	@GK_PROVISION_SUM,
			GK_PROVISION_TAX	=	@GK_PROVISION_TAX,
			EDO_SUM				=	@EDO_SUM,
			EDO_TAX				=	@EDO_TAX,
			ID_VENDOR			=	@ID_VENDOR,
			PROTOCOL			=	@PROTOCOL,
			AGREE				=	@AGREE,
			GK_DIRECTION		=	@GK_DIRECTION,
			GK_SIGN				=	@GK_SIGN,
			GK_SIGN_FACT		=	@GK_SIGN_FACT,
			GK_NUM				=	@GK_NUM,
			GK_DATE				=	@GK_DATE,
			GK_DOP_NUM			=	@GK_DOP_NUM,
			GK_DOP_DATE			=	@GK_DOP_DATE,
			PROVISION_RETURN	=	@PROVISION_RETURN,
			TOTAL				=	@TOTAL,
			PART_SUM			=	@PART_SUM,
			TARIFF_SUM			=	@TARIFF_SUM,
			ECP_SUM				=	@ECP_SUM,
			INVOICE_NUM			=	@INVOICE_NUM,
			INVOICE_DATE		=	@INVOICE_DATE
		WHERE ID_TENDER = @TENDER

		IF @@ROWCOUNT = 0
			INSERT INTO Tender.Placement(ID_TENDER, SUBJECT, ID_TYPE, NOTICE_NUM, DATE, GK_SUM, ID_TRADESITE, URL, GK_START, GK_FINISH, GK_MONTH, ACTUAL_START, ACTUAL_FINISH, ACTUAL_MONTH, CLAIM_START, CLAIM_FINISH, OPENING, REVIEW, AUCTION, CLAIM_PRIVISION, GK_PROVISION_PRC, GK_PROVISION_SUM, GK_PROVISION_TAX, EDO_SUM, EDO_TAX, ID_VENDOR, PROTOCOL, AGREE, GK_DIRECTION, GK_SIGN, GK_SIGN_FACT, GK_NUM, GK_DATE, GK_DOP_NUM, GK_DOP_DATE, PROVISION_RETURN, TOTAL, PART_SUM, TARIFF_SUM, ECP_SUM, INVOICE_NUM, INVOICE_DATE)
				VALUES(@TENDER, @SUBJECT, @ID_TYPE, @NOTICE_NUM, @DATE, @GK_SUM, @ID_TRADESITE, @URL, @GK_START, @GK_FINISH, @GK_MONTH, @ACTUAL_START, @ACTUAL_FINISH, @ACTUAL_MONTH, @CLAIM_START, @CLAIM_FINISH, @OPENING, @REVIEW, @AUCTION, @CLAIM_PRIVISION, @GK_PROVISION_PRC, @GK_PROVISION_SUM, @GK_PROVISION_TAX, @EDO_SUM, @EDO_TAX, @ID_VENDOR, @PROTOCOL, @AGREE, @GK_DIRECTION, @GK_SIGN, @GK_SIGN_FACT, @GK_NUM, @GK_DATE, @GK_DOP_NUM, @GK_DOP_DATE, @PROVISION_RETURN, @TOTAL, @PART_SUM, @TARIFF_SUM, @ECP_SUM, @INVOICE_NUM, @INVOICE_DATE)

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [Tender].[PLACEMENT_SAVE] TO rl_tender_u;
GO