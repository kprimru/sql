USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Purchase].[CLIENT_CONDITION_CARD_SAVE]
	@ID					UNIQUEIDENTIFIER,
	@CLIENT				INT,
	@DATE_PUB			SMALLDATETIME,
	@DATE_UPDATE		SMALLDATETIME,
	@DATE_COMPOSE		SMALLDATETIME,
	@DATE_ACTUAL		SMALLDATETIME,
	@LAWYER				UNIQUEIDENTIFIER,	
	@APPLY_REASON		BIT,
	@ID_APPLY_REASON	VARCHAR(MAX),
	@ID_ACTIVITY		VARCHAR(MAX),
	@ID_REASON			VARCHAR(MAX),		
	@CLAUSE_EXISTS		BIT,
	@CLAUSE_LINK		VARCHAR(MAX),
	@CLAUSE_CLIENT_LINK	VARCHAR(MAX),
	@TRADEMARK			BIT,
	@ID_TRADEMARK		VARCHAR(MAX),	
	@REQ_GOOD			BIT,
	@ID_REQ_GOOD		VARCHAR(MAX),	
	@REQ_PARTNER		BIT,
	@ID_REQ_PARTNER		VARCHAR(MAX),		
	@VALID_PRICE		BIT,
	@ID_VALID_PRICE		VARCHAR(MAX),	
	@TRADE_SITE			VARCHAR(MAX)	
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

		IF @ID IS NOT NULL
		BEGIN
			EXEC Purchase.CLIENT_CONDITION_CARD_ARCHIEVE @ID

			UPDATE Purchase.ClientConditionCard
			SET	CC_DATE_PUB				=	@DATE_PUB,
				CC_DATE_UPDATE			=	@DATE_UPDATE,
				CC_DATE_COMPOSE			=	@DATE_COMPOSE,
				CC_DATE_ACTUAL			=	@DATE_ACTUAL,
				CC_ID_LAWYER			=	@LAWYER,			
				CC_APPLY_REASON			=	@APPLY_REASON,						
				CC_CLAUSE_EXISTS		=	@CLAUSE_EXISTS,
				CC_CLAUSE_LINK			=	@CLAUSE_LINK,
				CC_CLAUSE_CLIENT_LINK	=	@CLAUSE_CLIENT_LINK,						
				CC_TRADEMARK			=	@TRADEMARK,
				CC_COMMON_REQ_GOOD		=	@REQ_GOOD,
				CC_COMMON_REQ_PARTNER	=	@REQ_PARTNER,
				CC_VALIDATION_PRICE		=	@VALID_PRICE,
				CC_LAST_UPDATE			=	GETDATE(),
				CC_LAST_UPDATE_USER		=	ORIGINAL_LOGIN()
			WHERE CC_ID = @ID

			DELETE FROM Purchase.ClientConditionTradeSite
			WHERE CTS_ID_CC = @ID
				AND CTS_ID_TS NOT IN
					(
						SELECT ID
						FROM dbo.TableGUIDFromXML(@TRADE_SITE)
					)

			INSERT INTO Purchase.ClientConditionTradeSite(CTS_ID_CC, CTS_ID_TS)
				SELECT @ID, ID
				FROM dbo.TableGUIDFromXML(@TRADE_SITE)
				WHERE NOT EXISTS
					(
						SELECT *
						FROM Purchase.ClientConditionTradeSite
						WHERE CTS_ID_CC = @ID AND CTS_ID_TS = ID
					)

			DELETE FROM Purchase.ClientConditionReason
			WHERE CCR_ID_CC = @ID
				AND CCR_ID_PR NOT IN
					(
						SELECT ID
						FROM dbo.TableGUIDFromXML(@ID_REASON)
					)

			INSERT INTO Purchase.ClientConditionReason(CCR_ID_CC, CCR_ID_PR)
				SELECT @ID, ID
				FROM dbo.TableGUIDFromXML(@ID_REASON)
				WHERE NOT EXISTS
					(
						SELECT *
						FROM Purchase.ClientConditionReason
						WHERE CCR_ID_CC = @ID AND CCR_ID_PR = ID
					)

			IF @APPLY_REASON = 0
			BEGIN
				DELETE FROM Purchase.ClientConditionApplyReason
				WHERE CAR_ID_CC = @ID
					AND CAR_ID_AR NOT IN
						(
							SELECT ID
							FROM dbo.TableGUIDFromXML(@ID_APPLY_REASON)
						)

				INSERT INTO Purchase.ClientConditionApplyReason(CAR_ID_CC, CAR_ID_AR)
					SELECT @ID, ID
					FROM dbo.TableGUIDFromXML(@ID_APPLY_REASON)
					WHERE NOT EXISTS
						(
							SELECT *
							FROM Purchase.ClientConditionApplyReason
							WHERE CAR_ID_CC = @ID AND CAR_ID_AR = ID
						)
			END
			ELSE
				DELETE FROM Purchase.ClientConditionApplyReason
				WHERE CAR_ID_CC = @ID


			DELETE FROM Purchase.ClientConditionActivity
			WHERE CCA_ID_CC = @ID
				AND CCA_ID_AC NOT IN
					(
						SELECT ID
						FROM dbo.TableGUIDFromXML(@ID_ACTIVITY)
					)

			INSERT INTO Purchase.ClientConditionActivity(CCA_ID_CC, CCA_ID_AC)
				SELECT @ID, ID
				FROM dbo.TableGUIDFromXML(@ID_ACTIVITY)
				WHERE NOT EXISTS
					(
						SELECT *
						FROM Purchase.ClientConditionActivity
						WHERE CCA_ID_CC = @ID AND CCA_ID_AC = ID
					)

			



			DELETE FROM Purchase.ClientConditionTrademark
			WHERE CCT_ID_CC = @ID
				AND CCT_ID_TM NOT IN
					(
						SELECT ID
						FROM dbo.TableGUIDFromXML(@ID_TRADEMARK)
					)

			INSERT INTO Purchase.ClientConditionTrademark(CCT_ID_CC, CCT_ID_TM)
				SELECT @ID, ID
				FROM dbo.TableGUIDFromXML(@ID_TRADEMARK)
				WHERE NOT EXISTS
					(
						SELECT *
						FROM Purchase.ClientConditionTrademark
						WHERE CCT_ID_CC = @ID AND CCT_ID_TM = ID
					)

			DELETE FROM Purchase.ClientConditionGoodRequirement
			WHERE CCGR_ID_CC = @ID
				AND CCGR_ID_GR NOT IN
					(
						SELECT ID
						FROM dbo.TableGUIDFromXML(@ID_REQ_GOOD)
					)

			INSERT INTO Purchase.ClientConditionGoodRequirement(CCGR_ID_CC, CCGR_ID_GR)
				SELECT @ID, ID
				FROM dbo.TableGUIDFromXML(@ID_REQ_GOOD)
				WHERE NOT EXISTS
					(
						SELECT *
						FROM Purchase.ClientConditionGoodRequirement
						WHERE CCGR_ID_CC = @ID AND CCGR_ID_GR = ID
					)
		
			DELETE FROM Purchase.ClientConditionPartnerRequirement
			WHERE CCPR_ID_CC = @ID
				AND CCPR_ID_PR NOT IN
					(
						SELECT ID
						FROM dbo.TableGUIDFromXML(@ID_REQ_PARTNER)
					)

			INSERT INTO Purchase.ClientConditionPartnerRequirement(CCPR_ID_CC, CCPR_ID_PR)
				SELECT @ID, ID
				FROM dbo.TableGUIDFromXML(@ID_REQ_PARTNER)
				WHERE NOT EXISTS
					(
						SELECT *
						FROM Purchase.ClientConditionPartnerRequirement
						WHERE CCPR_ID_CC = @ID AND CCPR_ID_PR = ID
					)

			DELETE FROM Purchase.ClientConditionPriceValidation
			WHERE CCPV_ID_CC = @ID
				AND CCPV_ID_PV NOT IN
					(
						SELECT ID
						FROM dbo.TableGUIDFromXML(@ID_VALID_PRICE)
					)

			INSERT INTO Purchase.ClientConditionPriceValidation(CCPV_ID_CC, CCPV_ID_PV)
				SELECT @ID, ID
				FROM dbo.TableGUIDFromXML(@ID_VALID_PRICE)
				WHERE NOT EXISTS
					(
						SELECT *
						FROM Purchase.ClientConditionPriceValidation
						WHERE CCPV_ID_CC = @ID AND CCPV_ID_PV = ID
					)
		END
		ELSE
		BEGIN
			DECLARE @TBL TABLE (ID UNIQUEIDENTIFIER)
			INSERT INTO Purchase.ClientConditionCard(
							CC_ID_CLIENT, CC_DATE_PUB, CC_DATE_UPDATE, CC_DATE_COMPOSE, CC_DATE_ACTUAL, CC_ID_LAWYER, 
							CC_APPLY_REASON, CC_CLAUSE_EXISTS, CC_CLAUSE_LINK, CC_CLAUSE_CLIENT_LINK, 
							CC_TRADEMARK, CC_COMMON_REQ_GOOD, CC_COMMON_REQ_PARTNER, CC_VALIDATION_PRICE)
				OUTPUT inserted.CC_ID INTO @TBL
				VALUES(
							@CLIENT, @DATE_PUB, @DATE_UPDATE, @DATE_COMPOSE, @DATE_ACTUAL, @LAWYER,
							@APPLY_REASON, @CLAUSE_EXISTS, @CLAUSE_LINK, @CLAUSE_CLIENT_LINK, 
							@TRADEMARK, @REQ_GOOD, @REQ_PARTNER, @VALID_PRICE)

			SELECT @ID = ID FROM @TBL

			INSERT INTO Purchase.ClientConditionTradeSite(CTS_ID_CC, CTS_ID_TS)
				SELECT @ID, ID
				FROM dbo.TableGUIDFromXML(@TRADE_SITE)

			INSERT INTO Purchase.ClientConditionReason(CCR_ID_CC, CCR_ID_PR)
				SELECT @ID, ID
				FROM dbo.TableGUIDFromXML(@ID_REASON)

			INSERT INTO Purchase.ClientConditionApplyReason(CAR_ID_CC, CAR_ID_AR)
				SELECT @ID, ID
				FROM dbo.TableGUIDFromXML(@ID_APPLY_REASON)

			INSERT INTO Purchase.ClientConditionActivity(CCA_ID_CC, CCA_ID_AC)
				SELECT @ID, ID
				FROM dbo.TableGUIDFromXML(@ID_ACTIVITY)

			INSERT INTO Purchase.ClientConditionTrademark(CCT_ID_CC, CCT_ID_TM)
				SELECT @ID, ID
				FROM dbo.TableGUIDFromXML(@ID_TRADEMARK)

			INSERT INTO Purchase.ClientConditionGoodRequirement(CCGR_ID_CC, CCGR_ID_GR)
				SELECT @ID, ID
				FROM dbo.TableGUIDFromXML(@ID_REQ_GOOD)

			INSERT INTO Purchase.ClientConditionpartnerRequirement(CCPR_ID_CC, CCPR_ID_PR)
				SELECT @ID, ID
				FROM dbo.TableGUIDFromXML(@ID_REQ_PARTNER)

			INSERT INTO Purchase.ClientConditionPriceValidation(CCPV_ID_CC, CCPV_ID_PV)
				SELECT @ID, ID
				FROM dbo.TableGUIDFromXML(@ID_VALID_PRICE)
		END
		
		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();
		
		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;
		
		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END