USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[Purchase].[CLIENT_CONDITION_PLACEMENT_SELECT]', 'P ') IS NULL EXEC('CREATE PROCEDURE [Purchase].[CLIENT_CONDITION_PLACEMENT_SELECT]  AS SELECT 1')
GO
CREATE OR ALTER PROCEDURE [Purchase].[CLIENT_CONDITION_PLACEMENT_SELECT]
	@CLIENT	INT,
	@CC_ID	UNIQUEIDENTIFIER
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

		IF @CLIENT IS NOT NULL
			SELECT @CC_ID = CC_ID
			FROM Purchase.ClientConditionCard
			WHERE CC_ID_CLIENT = @CLIENT AND CC_STATUS = 1

		SELECT
			PO_ID, PO_NAME, PO_NUM,
			CONVERT(BIT, CASE WHEN CPO_ID IS NULL THEN 0 ELSE 1 END) AS PO_CHECKED,
			CPO_USE_CONDITION, CPO_CLAIM_CANCEL_REASON, CPO_CLAIM_PROVISION,
			CPO_CONTRACT_PROVISION, CPO_DOCUMENT, CPO_OTHER_PROVISION,
			('<LIST>' +
				(
					SELECT '{' + CONVERT(VARCHAR(50), ID_UC) + '}' AS ITEM
					FROM Purchase.ClientConditionPlacementOrderUseCondition
					WHERE ID_CPO = CPO_ID
					ORDER BY ID_UC FOR XML PATH('')
				)
			+ '</LIST>') AS CPO_UC_ID,
			('<LIST>' +
				(
					SELECT '{' + CONVERT(VARCHAR(50), ID_CCR) + '}' AS ITEM
					FROM Purchase.ClientConditionPlacementOrderClaimCancelReason
					WHERE ID_CPO = CPO_ID
					ORDER BY ID_CCR FOR XML PATH('')
				)
			+ '</LIST>') AS CPO_CCR_ID,
			('<LIST>' +
				(
					SELECT '{' + CONVERT(VARCHAR(50), ID_CP) + '}' AS ITEM
					FROM Purchase.ClientConditionPlacementOrderClaimProvision
					WHERE ID_CPO = CPO_ID
					ORDER BY ID_CP FOR XML PATH('')
				)
			+ '</LIST>') AS CPO_CP_ID,
			('<LIST>' +
				(
					SELECT '{' + CONVERT(VARCHAR(50), ID_CEP) + '}' AS ITEM
					FROM Purchase.ClientConditionPlacementOrderContractExecutionProvision
					WHERE ID_CPO = CPO_ID
					ORDER BY ID_CEP FOR XML PATH('')
				)
			+ '</LIST>') AS CPO_CEP_ID,
			('<LIST>' +
				(
					SELECT '{' + CONVERT(VARCHAR(50), ID_DC) + '}' AS ITEM
					FROM Purchase.ClientConditionPlacementOrderDocument
					WHERE ID_CPO = CPO_ID
					ORDER BY ID_DC FOR XML PATH('')
				)
			+ '</LIST>') AS CPO_DC_ID,
			('<LIST>' +
				(
					SELECT '{' + CONVERT(VARCHAR(50), ID_OP) + '}' AS ITEM
					FROM Purchase.ClientConditionPlacementOrderOtherProvision
					WHERE ID_CPO = CPO_ID
					ORDER BY ID_OP FOR XML PATH('')
				)
			+ '</LIST>') AS CPO_OP_ID
		FROM
			Purchase.PlacementOrder
			LEFT OUTER JOIN Purchase.ClientConditionPlacementOrder ON CPO_ID_PO = PO_ID AND CPO_ID_CC = @CC_ID
		ORDER BY PO_NUM, PO_NAME

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [Purchase].[CLIENT_CONDITION_PLACEMENT_SELECT] TO rl_condition_card_r;
GO
