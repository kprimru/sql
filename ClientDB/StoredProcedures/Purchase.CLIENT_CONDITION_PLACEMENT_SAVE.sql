USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Purchase].[CLIENT_CONDITION_PLACEMENT_SAVE]
	@CLIENT				INT,
	@PO_ID				UNIQUEIDENTIFIER,
	@CHECKED			BIT,
	@USE_CONDITION		BIT,
	@USE_CONDITION_ID	VARCHAR(MAX),
	@CLAIM_CANCEL		BIT,
	@CLAIM_CANCEL_ID	VARCHAR(MAX),
	@CLAIM_PROVISION	BIT,
	@CLAIM_PROVISION_ID	VARCHAR(MAX),
	@CON_PROVISION		BIT,
	@CON_PROVISION_ID	VARCHAR(MAX),
	@DOCUMENT			BIT,
	@DOCUMENT_ID		VARCHAR(MAX),
	@OTHER_PROVISION	BIT = NULL,
	@OTHER_PROVISION_ID	VARCHAR(MAX) = NULL
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

		DECLARE @CC_ID	UNIQUEIDENTIFIER

		SELECT @CC_ID = CC_ID
		FROM Purchase.ClientConditionCard
		WHERE CC_ID_CLIENT = @CLIENT AND CC_STATUS = 1

		DECLARE @CPO_ID	UNIQUEIDENTIFIER

		SELECT @CPO_ID = CPO_ID
		FROM Purchase.ClientConditionPlacementOrder
		WHERE CPO_ID_CC = @CC_ID
			AND CPO_ID_PO = @PO_ID

		IF @CHECKED = 0 AND @CPO_ID IS NOT NULL
		BEGIN
			/* удаляем */
			DELETE 
			FROM Purchase.ClientConditionPlacementOrderClaimCancelReason
			WHERE ID_CPO = @CPO_ID

			DELETE 
			FROM Purchase.ClientConditionPlacementOrderClaimProvision
			WHERE ID_CPO = @CPO_ID

			DELETE 
			FROM Purchase.ClientConditionPlacementOrderContractExecutionProvision
			WHERE ID_CPO = @CPO_ID

			DELETE 
			FROM Purchase.ClientConditionPlacementOrderDocument
			WHERE ID_CPO = @CPO_ID

			DELETE 
			FROM Purchase.ClientConditionPlacementOrderUseCondition
			WHERE ID_CPO = @CPO_ID

			DELETE 
			FROM Purchase.ClientConditionPlacementOrderOtherProvision
			WHERE ID_CPO = @CPO_ID

			DELETE 
			FROM Purchase.ClientConditionPlacementOrder
			WHERE CPO_ID = @CPO_ID
		END
		ELSE IF @CHECKED = 1 AND @CPO_ID IS NOT NULL
		BEGIN
			/* изменяем */
			UPDATE Purchase.ClientConditionPlacementOrder
			SET	CPO_USE_CONDITION		=	@USE_CONDITION,			
				CPO_CLAIM_CANCEL_REASON	=	@CLAIM_CANCEL,			
				CPO_CLAIM_PROVISION		=	@CLAIM_PROVISION,			
				CPO_CONTRACT_PROVISION	=	@CON_PROVISION,			
				CPO_DOCUMENT			=	@DOCUMENT,
				CPO_OTHER_PROVISION		=	@OTHER_PROVISION
			WHERE CPO_ID = @CPO_ID
		END
		ELSE IF @CHECKED = 1 AND @CPO_ID IS NULL
		BEGIN
			/* добавляем */
			DECLARE @TBL TABLE (ID UNIQUEIDENTIFIER)

			INSERT INTO Purchase.ClientConditionPlacementOrder(
										CPO_ID_CC, CPO_ID_PO, 
										CPO_USE_CONDITION, CPO_CLAIM_CANCEL_REASON, CPO_CLAIM_PROVISION, 
										CPO_CONTRACT_PROVISION, CPO_DOCUMENT, CPO_OTHER_PROVISION)
			OUTPUT inserted.CPO_ID INTO @TBL
				VALUES(
							@CC_ID, @PO_ID, 
							@USE_CONDITION, @CLAIM_CANCEL, @CLAIM_PROVISION, 
							@CON_PROVISION, @DOCUMENT, @OTHER_PROVISION)

			SELECT @CPO_ID = ID
			FROM @TBL
		END
		/*
		ELSE IF @CHECKED = 0 AND @CPO_ID IS NULL
		BEGIN
			/* ничего не надо делать.*/
			
		END
		*/

		DELETE FROM Purchase.ClientConditionPlacementOrderDocument
		WHERE ID_CPO = @CPO_ID 
			AND ID_DC NOT IN
				(
					SELECT ID
					FROM dbo.TableGUIDFromXML(@DOCUMENT_ID)
				)

		INSERT INTO Purchase.ClientConditionPlacementOrderDocument(ID_CPO, ID_DC)
			SELECT @CPO_ID, ID
			FROM dbo.TableGUIDFromXML(@DOCUMENT_ID) a
			WHERE NOT EXISTS
				(
					SELECT *
					FROM Purchase.ClientConditionPlacementOrderDocument b
					WHERE ID_CPO = @CPO_ID
						AND ID_DC = a.ID
				)

		DELETE FROM Purchase.ClientConditionPlacementOrderClaimProvision
		WHERE ID_CPO = @CPO_ID 
			AND ID_CP NOT IN
				(
					SELECT ID
					FROM dbo.TableGUIDFromXML(@CLAIM_PROVISION_ID)
				)

		INSERT INTO Purchase.ClientConditionPlacementOrderClaimProvision(ID_CPO, ID_CP)
			SELECT @CPO_ID, ID
			FROM dbo.TableGUIDFromXML(@CLAIM_PROVISION_ID) a
			WHERE NOT EXISTS
				(
					SELECT *
					FROM Purchase.ClientConditionPlacementOrderClaimProvision b
					WHERE ID_CPO = @CPO_ID
						AND ID_CP = a.ID
				)

		DELETE FROM Purchase.ClientConditionPlacementOrderClaimCancelReason
		WHERE ID_CPO = @CPO_ID 
			AND ID_CCR NOT IN
				(
					SELECT ID
					FROM dbo.TableGUIDFromXML(@CLAIM_CANCEL_ID)
				)

		INSERT INTO Purchase.ClientConditionPlacementOrderClaimCancelReason(ID_CPO, ID_CCR)
			SELECT @CPO_ID, ID
			FROM dbo.TableGUIDFromXML(@CLAIM_CANCEL_ID) a
			WHERE NOT EXISTS
				(
					SELECT *
					FROM Purchase.ClientConditionPlacementOrderClaimCancelReason b
					WHERE ID_CPO = @CPO_ID
						AND ID_CCR = a.ID
				)

		DELETE FROM Purchase.ClientConditionPlacementOrderUseCondition
		WHERE ID_CPO = @CPO_ID 
			AND ID_UC NOT IN
				(
					SELECT ID
					FROM dbo.TableGUIDFromXML(@USE_CONDITION_ID)
				)

		INSERT INTO Purchase.ClientConditionPlacementOrderUseCondition(ID_CPO, ID_UC)
			SELECT @CPO_ID, ID
			FROM dbo.TableGUIDFromXML(@USE_CONDITION_ID) a
			WHERE NOT EXISTS
				(
					SELECT *
					FROM Purchase.ClientConditionPlacementOrderUseCondition b
					WHERE ID_CPO = @CPO_ID
						AND ID_UC = a.ID
				)

		DELETE FROM Purchase.ClientConditionPlacementOrderContractExecutionProvision
		WHERE ID_CPO = @CPO_ID 
			AND ID_CEP NOT IN
				(
					SELECT ID
					FROM dbo.TableGUIDFromXML(@CON_PROVISION_ID)
				)	
		
		INSERT INTO Purchase.ClientConditionPlacementOrderContractExecutionProvision(ID_CPO, ID_CEP)
			SELECT @CPO_ID, ID
			FROM dbo.TableGUIDFromXML(@CON_PROVISION_ID) a
			WHERE NOT EXISTS
				(
					SELECT *
					FROM Purchase.ClientConditionPlacementOrderContractExecutionProvision b
					WHERE ID_CPO = @CPO_ID
						AND ID_CEP = a.ID
				)

		DELETE FROM Purchase.ClientConditionPlacementOrderOtherProvision
		WHERE ID_CPO = @CPO_ID 
			AND ID_OP NOT IN
				(
					SELECT ID
					FROM dbo.TableGUIDFromXML(@OTHER_PROVISION_ID)
				)

		INSERT INTO Purchase.ClientConditionPlacementOrderOtherProvision(ID_CPO, ID_OP)
			SELECT @CPO_ID, ID
			FROM dbo.TableGUIDFromXML(@OTHER_PROVISION_ID) a
			WHERE NOT EXISTS
				(
					SELECT *
					FROM Purchase.ClientConditionPlacementOrderOtherProvision b
					WHERE ID_CPO = @CPO_ID
						AND ID_OP = a.ID
				)
				
		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();
		
		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;
		
		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END