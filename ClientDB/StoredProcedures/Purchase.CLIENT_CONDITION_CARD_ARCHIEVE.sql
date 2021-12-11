USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[Purchase].[CLIENT_CONDITION_CARD_ARCHIEVE]', 'P ') IS NULL EXEC('CREATE PROCEDURE [Purchase].[CLIENT_CONDITION_CARD_ARCHIEVE]  AS SELECT 1')
GO
ALTER PROCEDURE [Purchase].[CLIENT_CONDITION_CARD_ARCHIEVE]
    @ID	UNIQUEIDENTIFIER
AS
BEGIN
	SET NOCOUNT ON

	DECLARE
		@DebugError		VarChar(512),
		@DebugContext	Xml,
		@Params			Xml;

	EXEC [Debug].[Execution@Start]
		@Proc_Id		= @@ProcId,
		@Params			= @Params,
		@DebugContext	= @DebugContext OUT

	BEGIN TRY

		DECLARE @NEWID	UNIQUEIDENTIFIER

		DECLARE @TBL TABLE (ID UNIQUEIDENTIFIER)

		INSERT INTO Purchase.ClientConditionCard(
					CC_ID_MASTER, CC_ID_CLIENT, CC_DATE_PUB, CC_DATE_UPDATE, CC_DATE_COMPOSE, CC_DATE_ACTUAL,
					CC_ID_LAWYER, CC_APPLY_REASON, CC_CLAUSE_EXISTS, CC_CLAUSE_LINK, CC_CLAUSE_CLIENT_LINK,
					CC_TRADEMARK, CC_COMMON_REQ_GOOD, CC_COMMON_REQ_PARTNER, CC_VALIDATION_PRICE,
					CC_STATUS, CC_LAST_UPDATE, CC_LAST_UPDATE_USER)
			OUTPUT inserted.CC_ID INTO @TBL
			SELECT
					@ID, CC_ID_CLIENT, CC_DATE_PUB, CC_DATE_UPDATE, CC_DATE_COMPOSE, CC_DATE_ACTUAL,
					CC_ID_LAWYER, CC_APPLY_REASON, CC_CLAUSE_EXISTS, CC_CLAUSE_LINK, CC_CLAUSE_CLIENT_LINK,
					CC_TRADEMARK, CC_COMMON_REQ_GOOD, CC_COMMON_REQ_PARTNER, CC_VALIDATION_PRICE,
					2, CC_LAST_UPDATE, CC_LAST_UPDATE_USER
			FROM Purchase.ClientConditionCard
			WHERE CC_ID = @ID

		SELECT @NEWID = ID
		FROM @TBL

		INSERT INTO Purchase.ClientConditionTradeSite(CTS_ID_CC, CTS_ID_TS)
			SELECT @NEWID, CTS_ID_TS
			FROM Purchase.ClientConditionTradeSite
			WHERE CTS_ID_CC = @ID

		INSERT INTO Purchase.ClientConditionReason(CCR_ID_CC, CCR_ID_PR)
			SELECT @NEWID, CCR_ID_PR
			FROM Purchase.ClientConditionReason
			WHERE CCR_ID_CC = @ID

		INSERT INTO Purchase.ClientConditionApplyReason(CAR_ID_CC, CAR_ID_AR)
			SELECT @NEWID, CAR_ID_AR
			FROM Purchase.ClientConditionApplyReason
			WHERE CAR_ID_CC = @ID

		INSERT INTO Purchase.ClientConditionActivity(CCA_ID_CC, CCA_ID_AC)
			SELECT @NEWID, CCA_ID_AC
			FROM Purchase.ClientConditionActivity
			WHERE CCA_ID_CC = @ID

		INSERT INTO Purchase.ClientConditionTrademark(CCT_ID_CC, CCT_ID_TM)
			SELECT @NEWID, CCT_ID_TM
			FROM Purchase.ClientConditionTrademark
			WHERE CCT_ID_CC = @ID

		INSERT INTO Purchase.ClientConditionGoodRequirement(CCGR_ID_CC, CCGR_ID_GR)
			SELECT @NEWID, CCGR_ID_GR
			FROM Purchase.ClientConditionGoodRequirement
			WHERE CCGR_ID_CC = @ID

		INSERT INTO Purchase.ClientConditionPartnerRequirement(CCPR_ID_CC, CCPR_ID_PR)
			SELECT @NEWID, CCPR_ID_PR
			FROM Purchase.ClientConditionPartnerRequirement
			WHERE CCPR_ID_CC = @ID

		INSERT INTO Purchase.ClientConditionPriceValidation(CCPV_ID_CC, CCPV_ID_PV)
			SELECT @NEWID, CCPV_ID_PV
			FROM Purchase.ClientConditionPriceValidation
			WHERE CCPV_ID_PV = @ID

		DECLARE @CPO TABLE(NEW UNIQUEIDENTIFIER, OLD UNIQUEIDENTIFIER)

		INSERT INTO Purchase.ClientConditionPlacementOrder(
					CPO_ID_CC, CPO_ID_PO, OLD_ID,
					CPO_USE_CONDITION, CPO_CLAIM_CANCEL_REASON, CPO_CLAIM_PROVISION,
					CPO_CONTRACT_PROVISION, CPO_DOCUMENT, CPO_OTHER_PROVISION)
			OUTPUT inserted.CPO_ID, inserted.OLD_ID INTO @CPO
			SELECT
					@NEWID, CPO_ID_PO, CPO_ID,
					CPO_USE_CONDITION, CPO_CLAIM_CANCEL_REASON, CPO_CLAIM_PROVISION,
					CPO_CONTRACT_PROVISION, CPO_DOCUMENT, CPO_OTHER_PROVISION
			FROM Purchase.ClientConditionPlacementOrder a
			WHERE CPO_ID_CC = @ID

		INSERT INTO Purchase.ClientConditionPlacementOrderClaimCancelReason(ID_CPO, ID_CCR)
			SELECT NEW, ID_CCR
			FROM
				Purchase.ClientConditionPlacementOrderClaimCancelReason
				INNER JOIN @CPO ON ID_CPO = OLD

		INSERT INTO Purchase.ClientConditionPlacementOrderClaimProvision(ID_CPO, ID_CP)
			SELECT NEW, ID_CP
			FROM
				Purchase.ClientConditionPlacementOrderClaimProvision
				INNER JOIN @CPO ON ID_CPO = OLD

		INSERT INTO Purchase.ClientConditionPlacementOrderContractExecutionProvision(ID_CPO, ID_CEP)
			SELECT NEW, ID_CEP
			FROM
				Purchase.ClientConditionPlacementOrderContractExecutionProvision
				INNER JOIN @CPO ON ID_CPO = OLD

		INSERT INTO Purchase.ClientConditionPlacementOrderDocument(ID_CPO, ID_DC)
			SELECT NEW, ID_DC
			FROM
				Purchase.ClientConditionPlacementOrderDocument
				INNER JOIN @CPO ON ID_CPO = OLD

		INSERT INTO Purchase.ClientConditionPlacementOrderUseCondition(ID_CPO, ID_UC)
			SELECT NEW, ID_UC
			FROM
				Purchase.ClientConditionPlacementOrderUseCondition
				INNER JOIN @CPO ON ID_CPO = OLD

		INSERT INTO Purchase.ClientConditionPlacementOrderOtherProvision(ID_CPO, ID_OP)
			SELECT NEW, ID_OP
			FROM
				Purchase.ClientConditionPlacementOrderOtherProvision
				INNER JOIN @CPO ON ID_CPO = OLD

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
