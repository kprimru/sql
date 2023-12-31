USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [Tender].[OFFER_SAVE]
	@ID				UNIQUEIDENTIFIER OUTPUT,
	@TENDER			UNIQUEIDENTIFIER,
	@VENDOR			UNIQUEIDENTIFIER,
	@TAX			UNIQUEIDENTIFIER,
	@ACTUAL			BIT,
	@ACTUAL_START	SMALLDATETIME,
	@ACTUAL_FINISH	SMALLDATETIME,
	@ACTUAL_DATE	SMALLDATETIME,
	@ACTUAL_TYPES	NVARCHAR(MAX),
	@ACTUAL_COEF	DECIMAL(8, 4),
	@EXCHANGE		BIT,
	@EXCHANGE_TYPES	NVARCHAR(MAX),
	@EXCHANGE_COEF	DECIMAL(8, 4),
	@DELIVERY		BIT,
	@DELIVERY_TYPES	NVARCHAR(MAX),
	@DELIVERY_COEF	DECIMAL(8, 4),
	@SUPPORT		BIT,
	@SUPPORT_START	SMALLDATETIME,
	@SUPPORT_FINISH	SMALLDATETIME,
	@SUPPORT_TYPES	NVARCHAR(MAX),
	@SUPPORT_COEF	DECIMAL(8, 4),
	@QUERY_DATE		SMALLDATETIME,
	@TPL			NVARCHAR(128)
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

			INSERT INTO Tender.Offer(ID_TENDER, ID_VENDOR, ID_TAX, ACTUAL, ACTUAL_START, ACTUAL_FINISH, ACTUAL_DATE, ACTUAL_TYPES, ACTUAL_COEF, EXCHANGE, EXCHANGE_TYPES, EXCHANGE_COEF, DELIVERY, DELIVERY_TYPES, DELIVERY_COEF, SUPPORT, SUPPORT_START, SUPPORT_FINISH, SUPPORT_TYPES, SUPPORT_COEF, QUERY_DATE, TPL)
				OUTPUT inserted.ID INTO @TBL
				VALUES(@TENDER, @VENDOR, @TAX, @ACTUAL, @ACTUAL_START, @ACTUAL_FINISH, @ACTUAL_DATE, @ACTUAL_TYPES, @ACTUAL_COEF, @EXCHANGE, @EXCHANGE_TYPES, @EXCHANGE_COEF, @DELIVERY, @DELIVERY_TYPES, @DELIVERY_COEF, @SUPPORT, @SUPPORT_START, @SUPPORT_FINISH, @SUPPORT_TYPES, @SUPPORT_COEF, @QUERY_DATE, @TPL)

			SELECT @ID = ID FROM @TBL
		END
		ELSE
		BEGIN
			EXEC Tender.OFFER_ARCH @ID

			UPDATE Tender.Offer
			SET ID_VENDOR		=	@VENDOR,
				ID_TAX			=	@TAX,
				ACTUAL			=	@ACTUAL,
				ACTUAL_START	=	@ACTUAL_START,
				ACTUAL_FINISH	=	@ACTUAL_FINISH,
				ACTUAL_DATE		=	@ACTUAL_DATE,
				ACTUAL_TYPES	=	@ACTUAL_TYPES,
				ACTUAL_COEF		=	@ACTUAL_COEF,
				EXCHANGE		=	@EXCHANGE,
				EXCHANGE_TYPES	=	@EXCHANGE_TYPES,
				EXCHANGE_COEF	=	@EXCHANGE_COEF,
				DELIVERY		=	@DELIVERY,
				DELIVERY_TYPES	=	@DELIVERY_TYPES,
				DELIVERY_COEF	=	@DELIVERY_COEF,
				SUPPORT			=	@SUPPORT,
				SUPPORT_START	=	@SUPPORT_START,
				SUPPORT_FINISH	=	@SUPPORT_FINISH,
				SUPPORT_TYPES	=	@SUPPORT_TYPES,
				SUPPORT_COEF	=	@SUPPORT_COEF,
				QUERY_DATE		=	@QUERY_DATE,
				TPL				=	@TPL,
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
GRANT EXECUTE ON [Tender].[OFFER_SAVE] TO rl_tender_offer_u;
GRANT EXECUTE ON [Tender].[OFFER_SAVE] TO rl_tender_u;
GO
