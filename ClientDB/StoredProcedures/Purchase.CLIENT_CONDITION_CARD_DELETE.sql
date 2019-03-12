USE [ClientDB]
	GO
	SET ANSI_NULLS ON
	GO
	SET QUOTED_IDENTIFIER ON
	GO
	CREATE PROCEDURE [Purchase].[CLIENT_CONDITION_CARD_DELETE]
	@ID	UNIQUEIDENTIFIER
AS
BEGIN
	SET NOCOUNT ON;

	DELETE 
	FROM Purchase.ClientConditionGoodRequirement
	WHERE CCGR_ID_CC IN
		(
			SELECT CC_ID
			FROM Purchase.ClientConditionCard
			WHERE CC_ID = @ID OR CC_ID_MASTER = @ID
		)

	DELETE 
	FROM Purchase.ClientConditionPartnerRequirement
	WHERE CCPR_ID_CC IN
		(
			SELECT CC_ID
			FROM Purchase.ClientConditionCard
			WHERE CC_ID = @ID OR CC_ID_MASTER = @ID
		)

	DELETE 
	FROM Purchase.ClientConditionPriceValidation
	WHERE CCPV_ID_CC IN
		(
			SELECT CC_ID
			FROM Purchase.ClientConditionCard
			WHERE CC_ID = @ID OR CC_ID_MASTER = @ID
		)

	DELETE 
	FROM Purchase.ClientConditionReason
	WHERE CCR_ID_CC IN
		(
			SELECT CC_ID
			FROM Purchase.ClientConditionCard
			WHERE CC_ID = @ID OR CC_ID_MASTER = @ID
		)

	DELETE 
	FROM Purchase.ClientConditionActivity
	WHERE CCA_ID_CC IN
		(
			SELECT CC_ID
			FROM Purchase.ClientConditionCard
			WHERE CC_ID = @ID OR CC_ID_MASTER = @ID
		)

	DELETE 
	FROM Purchase.ClientConditionApplyReason
	WHERE CAR_ID_CC IN
		(
			SELECT CC_ID
			FROM Purchase.ClientConditionCard
			WHERE CC_ID = @ID OR CC_ID_MASTER = @ID
		)

	DELETE 
	FROM Purchase.ClientConditionTrademark
	WHERE CCT_ID_CC IN
		(
			SELECT CC_ID
			FROM Purchase.ClientConditionCard
			WHERE CC_ID = @ID OR CC_ID_MASTER = @ID
		)

	DELETE 
	FROM Purchase.ClientConditionTradeSite
	WHERE CTS_ID_CC IN
		(
			SELECT CC_ID
			FROM Purchase.ClientConditionCard
			WHERE CC_ID = @ID OR CC_ID_MASTER = @ID
		)

	DELETE
	FROM Purchase.ClientConditionPlacementOrderClaimCancelReason
	WHERE ID_CPO IN
		(
			SELECT CPO_ID
			FROM Purchase.ClientConditionPlacementOrder
			WHERE CPO_ID_CC IN
				(
					SELECT CC_ID
					FROM Purchase.ClientConditionCard
					WHERE CC_ID = @ID OR CC_ID_MASTER = @ID
				)
		)

	DELETE
	FROM Purchase.ClientConditionPlacementOrderClaimProvision
	WHERE ID_CPO IN
		(
			SELECT CPO_ID
			FROM Purchase.ClientConditionPlacementOrder
			WHERE CPO_ID_CC IN
				(
					SELECT CC_ID
					FROM Purchase.ClientConditionCard
					WHERE CC_ID = @ID OR CC_ID_MASTER = @ID
				)
		)

	DELETE
	FROM Purchase.ClientConditionPlacementOrderContractExecutionProvision
	WHERE ID_CPO IN
		(
			SELECT CPO_ID
			FROM Purchase.ClientConditionPlacementOrder
			WHERE CPO_ID_CC IN
				(
					SELECT CC_ID
					FROM Purchase.ClientConditionCard
					WHERE CC_ID = @ID OR CC_ID_MASTER = @ID
				)
		)

	DELETE
	FROM Purchase.ClientConditionPlacementOrderDocument
	WHERE ID_CPO IN
		(
			SELECT CPO_ID
			FROM Purchase.ClientConditionPlacementOrder
			WHERE CPO_ID_CC IN
				(
					SELECT CC_ID
					FROM Purchase.ClientConditionCard
					WHERE CC_ID = @ID OR CC_ID_MASTER = @ID
				)
		)

	DELETE
	FROM Purchase.ClientConditionPlacementOrderUseCondition
	WHERE ID_CPO IN
		(
			SELECT CPO_ID
			FROM Purchase.ClientConditionPlacementOrder
			WHERE CPO_ID_CC IN
				(
					SELECT CC_ID
					FROM Purchase.ClientConditionCard
					WHERE CC_ID = @ID OR CC_ID_MASTER = @ID
				)
		)

	DELETE
	FROM Purchase.ClientConditionPlacementOrder
	WHERE CPO_ID_CC IN
		(
			SELECT CC_ID
			FROM Purchase.ClientConditionCard
			WHERE CC_ID = @ID OR CC_ID_MASTER = @ID
		)
	

	DELETE 
	FROM Purchase.ClientConditionCard
	WHERE CC_ID_MASTER = @ID

	DELETE 
	FROM Purchase.ClientConditionCard
	WHERE CC_ID = @ID
END