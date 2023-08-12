﻿USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[Purchase].[TENDER_SAVE]', 'P ') IS NULL EXEC('CREATE PROCEDURE [Purchase].[TENDER_SAVE]  AS SELECT 1')
GO
CREATE OR ALTER PROCEDURE [Purchase].[TENDER_SAVE]
	@ID						UNIQUEIDENTIFIER OUTPUT,
	@CLIENT					INT,
	@NOTICE_NUM				VARCHAR(50),
	@NOTICE_DATE			SMALLDATETIME,
	@ID_NAME				UNIQUEIDENTIFIER,
	@PURCHASE_KIND			VARCHAR(MAX),
	@TRADE_SITE				VARCHAR(MAX),
	@TCL_NAME				VARCHAR(500),
	@TCL_PLACE				VARCHAR(250),
	@TCL_ADDRESS			VARCHAR(250),
	@TCL_EMAIL				VARCHAR(150),
	@TCL_RES				VARCHAR(150),
	@TCL_PHONE				VARCHAR(150),
	@TCL_FAX				VARCHAR(150),
	@START_PRICE			MONEY,
	@PRICE_VALIDATION		VARCHAR(MAX),
	@CLAIM_SIZE				BIT,
	@CLAIM_SIZE_VALUE		MONEY,
	@CONTRACT_SIZE			BIT,
	@CONTRACT_SIZE_VALUE	MONEY,
	@CITY					VARCHAR(MAX),
	@DELIVERY_BEGIN			SMALLDATETIME,
	@DELIVERY_BEGIN_NOTE	VARCHAR(100),
	@DELIVERY_END			SMALLDATETIME,
	@DELIVERY_END_NOTE		VARCHAR(100),
	@ID_PAY_PERIOD			UNIQUEIDENTIFIER,
	@TI_CLAIM_START			DATETIME,
	@TI_CLAIM_END			DATETIME,
	@TI_CLAIM_EL_END		DATETIME,
	@TI_INSPECT_DATE		DATETIME,
	@TI_EL_DATE				DATETIME,
	@DOCUMENT				VARCHAR(MAX),
	@TI_ID_SIGN_PERIOD		UNIQUEIDENTIFIER,
	@CANCEL_DATE			SMALLDATETIME = NULL,
	@NOTE					NVARCHAR(MAX) = NULL
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

		IF @ID IS NOT NULL
		BEGIN
			EXEC Purchase.TENDER_ARCHIEVE @ID

			UPDATE Purchase.Tender
			SET TD_NOTICE_NUM	=	@NOTICE_NUM,
				TD_NOTICE_DATE	=	@NOTICE_DATE,
				TD_ID_NAME		=	@ID_NAME,
				TD_CANCEL_DATE	=	@CANCEL_DATE,
				TD_NOTE			=	@NOTE,
				TD_UPDATE		=	GETDATE(),
				TD_UPDATE_USER	=	ORIGINAL_LOGIN()
			WHERE TD_ID = @ID

			DELETE FROM Purchase.TenderPurchaseKind
			WHERE TPK_ID_TENDER = @ID
				AND TPK_ID_PK NOT IN
					(
						SELECT ID
						FROM dbo.TableGUIDFromXML(@PURCHASE_KIND)
					)

			INSERT INTO Purchase.TenderPurchaseKind(TPK_ID_TENDER, TPK_ID_PK)
				SELECT @ID, ID
				FROM dbo.TableGUIDFromXML(@PURCHASE_KIND)
				WHERE NOT EXISTS
					(
						SELECT *
						FROM Purchase.TenderPurchaseKind
						WHERE TPK_ID_TENDER = @ID AND TPK_ID_PK = ID
					)

			DELETE FROM Purchase.TenderTradeSite
			WHERE TTS_ID_TENDER = @ID
				AND TTS_ID_TS NOT IN
					(
						SELECT ID
						FROM dbo.TableGUIDFromXML(@TRADE_SITE)
					)

			INSERT INTO Purchase.TenderTradeSite(TTS_ID_TENDER, TTS_ID_TS)
				SELECT @ID, ID
				FROM dbo.TableGUIDFromXML(@TRADE_SITE)
				WHERE NOT EXISTS
					(
						SELECT *
						FROM Purchase.TenderTradeSite
						WHERE TTS_ID_TENDER = @ID AND TTS_ID_TS = ID
					)

			UPDATE Purchase.TenderClient
			SET	TCL_NAME	=	@TCL_NAME,
				TCL_PLACE	=	@TCL_PLACE,
				TCL_ADDRESS	=	@TCL_ADDRESS,
				TCL_EMAIL	=	@TCL_EMAIL,
				TCL_RES		=	@TCL_RES,
				TCL_PHONE	=	@TCL_PHONE,
				TCL_FAX		=	@TCL_FAX
			WHERE TCL_ID_TENDER = @ID

			UPDATE Purchase.TenderConditions
			SET TC_START_PRICE			=	@START_PRICE,
				TC_CLAIM_SIZE			=	@CLAIM_SIZE,
				TC_CLAIM_SIZE_VALUE		=	@CLAIM_SIZE_VALUE,
				TC_CONTRACT_SIZE		=	@CONTRACT_SIZE,
				TC_CONTRACT_SIZE_VALUE	=	@CONTRACT_SIZE_VALUE,
				TC_DELIVERY_BEGIN		=	@DELIVERY_BEGIN,
				TC_DELIVERY_BEGIN_NOTE	=	@DELIVERY_BEGIN_NOTE,
				TC_DELIVERY_END			=	@DELIVERY_END,
				TC_DELIVERY_END_NOTE	=	@DELIVERY_END_NOTE,
				TC_ID_PAY_PERIOD		=	@ID_PAY_PERIOD
			WHERE TC_ID_TENDER = @ID

			DELETE FROM Purchase.TenderPriceValidation
			WHERE TPV_ID_TENDER = @ID
				AND TPV_ID_PV NOT IN
					(
						SELECT ID
						FROM dbo.TableGUIDFromXML(@PRICE_VALIDATION)
					)

			INSERT INTO Purchase.TenderPriceValidation(TPV_ID_TENDER, TPV_ID_PV)
				SELECT @ID, ID
				FROM dbo.TableGUIDFromXML(@PRICE_VALIDATION)
				WHERE NOT EXISTS
					(
						SELECT *
						FROM Purchase.TenderPriceValidation
						WHERE TPV_ID_TENDER = @ID AND TPV_ID_PV = ID
					)

			DELETE FROM Purchase.TenderCity
			WHERE TCT_ID_TENDER = @ID
				AND TCT_ID_CITY NOT IN
					(
						SELECT ID
						FROM dbo.TableGUIDFromXML(@CITY)
					)

			INSERT INTO Purchase.TenderCity(TCT_ID_TENDER, TCT_ID_CITY)
				SELECT @ID, ID
				FROM dbo.TableGUIDFromXML(@CITY)
				WHERE NOT EXISTS
					(
						SELECT *
						FROM Purchase.TenderCity
						WHERE TCT_ID_TENDER = @ID AND TCT_ID_CITY = ID
					)

			UPDATE Purchase.TenderInfo
			SET TI_CLAIM_START		=	@TI_CLAIM_START,
				TI_CLAIM_END		=	@TI_CLAIM_END,
				TI_CLAIM_EL_END		=	@TI_CLAIM_EL_END,
				TI_INSPECT_DATE		=	@TI_INSPECT_DATE,
				TI_EL_DATE			=	@TI_EL_DATE,
				TI_ID_SIGN_PERIOD	=	@TI_ID_SIGN_PERIOD
			WHERE TI_ID_TENDER = @ID

			DELETE FROM Purchase.TenderDocument
			WHERE TDC_ID_TENDER = @ID
				AND TDC_ID_DC NOT IN
					(
						SELECT ID
						FROM dbo.TableGUIDFromXML(@DOCUMENT)
					)

			INSERT INTO Purchase.TenderDocument(TDC_ID_TENDER, TDC_ID_DC)
				SELECT @ID, ID
				FROM dbo.TableGUIDFromXML(@DOCUMENT)
				WHERE NOT EXISTS
					(
						SELECT *
						FROM Purchase.TenderDocument
						WHERE TDC_ID_TENDER = @ID AND TDC_ID_DC = ID
					)
		END
		ELSE
		BEGIN
			INSERT INTO Purchase.Tender(TD_ID_CLIENT, TD_NOTICE_NUM, TD_NOTICE_DATE, TD_ID_NAME)
				OUTPUT inserted.TD_ID INTO @TBL
				VALUES(@CLIENT, @NOTICE_NUM, @NOTICE_DATE, @ID_NAME)

			SELECT @ID = ID FROM @TBL

			INSERT INTO Purchase.TenderPurchaseKind(TPK_ID_TENDER, TPK_ID_PK)
				SELECT @ID, ID
				FROM dbo.TableGUIDFromXML(@PURCHASE_KIND)

			INSERT INTO Purchase.TenderTradeSite(TTS_ID_TENDER, TTS_ID_TS)
				SELECT @ID, ID
				FROM dbo.TableGUIDFromXML(@TRADE_SITE)

			INSERT INTO Purchase.TenderClient(TCL_ID_TENDER, TCL_NAME, TCL_PLACE, TCL_ADDRESS, TCL_EMAIL, TCL_RES, TCL_PHONE, TCL_FAX)
				VALUES(@ID, @TCL_NAME, @TCL_PLACE, @TCL_ADDRESS, @TCL_EMAIL, @TCL_RES, @TCL_PHONE, @TCL_FAX)

			INSERT INTO Purchase.TenderConditions(
					TC_ID_TENDER, TC_START_PRICE, TC_CLAIM_SIZE, TC_CLAIM_SIZE_VALUE,
					TC_CONTRACT_SIZE, TC_CONTRACT_SIZE_VALUE, TC_DELIVERY_BEGIN, TC_DELIVERY_BEGIN_NOTE,
					TC_DELIVERY_END, TC_DELIVERY_END_NOTE, TC_ID_PAY_PERIOD)
				VALUES(
					@ID, @START_PRICE, @CLAIM_SIZE, @CLAIM_SIZE_VALUE,
					@CONTRACT_SIZE, @CONTRACT_SIZE_VALUE, @DELIVERY_BEGIN, @DELIVERY_BEGIN_NOTE,
					@DELIVERY_END, @DELIVERY_END_NOTE, @ID_PAY_PERIOD)

			INSERT INTO Purchase.TenderPriceValidation(TPV_ID_TENDER, TPV_ID_PV)
				SELECT @ID, ID
				FROM dbo.TableGUIDFromXML(@PRICE_VALIDATION)

			INSERT INTO Purchase.TenderCity(TCT_ID_TENDER, TCT_ID_CITY)
				SELECT @ID, ID
				FROM dbo.TableGUIDFromXML(@CITY)

			INSERT INTO Purchase.TenderInfo(TI_ID_TENDER, TI_CLAIM_START, TI_CLAIM_END, TI_CLAIM_EL_END, TI_INSPECT_DATE, TI_EL_DATE, TI_ID_SIGN_PERIOD)
				VALUES(@ID, @TI_CLAIM_START, @TI_CLAIM_END, @TI_CLAIM_EL_END, @TI_INSPECT_DATE, @TI_EL_DATE, @TI_ID_SIGN_PERIOD)

			INSERT INTO Purchase.TenderDocument(TDC_ID_TENDER, TDC_ID_DC)
				SELECT @ID, ID
				FROM dbo.TableGUIDFromXML(@DOCUMENT)
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
GRANT EXECUTE ON [Purchase].[TENDER_SAVE] TO rl_tender_i;
GRANT EXECUTE ON [Purchase].[TENDER_SAVE] TO rl_tender_u;
GO
