USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[Purchase].[CLIENT_CONDITION_PRINT]', 'P ') IS NULL EXEC('CREATE PROCEDURE [Purchase].[CLIENT_CONDITION_PRINT]  AS SELECT 1')
GO
ALTER PROCEDURE [Purchase].[CLIENT_CONDITION_PRINT]
	@CL_ID	INT
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

		DECLARE @ID UNIQUEIDENTIFIER

		SELECT @ID = CC_ID
		FROM Purchase.ClientConditionCard
		WHERE CC_STATUS = 1 AND CC_ID_CLIENT = @CL_ID

		SELECT
			ClientFullName, CC_DATE_PUB, CC_DATE_UPDATE, CC_DATE_COMPOSE, CC_DATE_ACTUAL,
			LW_SHORT,
			REVERSE(STUFF(REVERSE(
				(
					SELECT AC_CODE + ' ' + ISNULL(AC_SHORT, AC_NAME) + CHAR(10)
					FROM
						dbo.Activity
						INNER JOIN Purchase.ClientConditionActivity ON AC_ID = CCA_ID_AC
					WHERE CCA_ID_CC = CC_ID
					ORDER BY
						dbo.StringDelimiterPartInt(AC_CODE, '.', 1),
						dbo.StringDelimiterPartInt(AC_CODE, '.', 2),
						dbo.StringDelimiterPartInt(AC_CODE, '.', 3),
						dbo.StringDelimiterPartInt(AC_CODE, '.', 4) FOR XML PATH('')
				)
			), 1, 1, '')) AS CC_ACTIVITY_STR,
			CC_APPLY_REASON,
			REVERSE(STUFF(REVERSE(
				(
					SELECT AR_SHORT + CHAR(10)
					FROM
						Purchase.ApplyReason
						INNER JOIN Purchase.ClientConditionApplyReason ON AR_ID = CAR_ID_AR
					WHERE CAR_ID_CC = CC_ID
					ORDER BY AR_SHORT FOR XML PATH('')
				)
			), 1, 1, '')) AS CC_APPLY_REASON_STR,
			REVERSE(STUFF(REVERSE(
				(
					SELECT PR_NAME + CHAR(10)
					FROM
						Purchase.PurchaseReason
						INNER JOIN Purchase.ClientConditionReason ON PR_ID = CCR_ID_PR
					WHERE CCR_ID_CC = CC_ID
					ORDER BY PR_NUM FOR XML PATH('')
				)
			), 1, 1, '')) AS CC_PURCHASE_REASON_STR,
			REVERSE(STUFF(REVERSE(
				(
					SELECT TS_SHORT + CHAR(10)
					FROM
						Purchase.TradeSite
						INNER JOIN Purchase.ClientConditionTradeSite ON TS_ID = CTS_ID_TS
					WHERE CTS_ID_CC = CC_ID
					ORDER BY TS_SHORT FOR XML PATH('')
				)
			), 1, 1, '')) AS CC_TRADESITE_STR,
			CC_CLAUSE_EXISTS, CC_CLAUSE_LINK, CC_CLAUSE_CLIENT_LINK,
			CC_TRADEMARK,
			REVERSE(STUFF(REVERSE(
				(
					SELECT TM_SHORT + CHAR(10)
					FROM
						Purchase.Trademark
						INNER JOIN Purchase.ClientConditionTrademark ON CCT_ID_TM = TM_ID
					WHERE CCT_ID_CC = CC_ID
					ORDER BY TM_SHORT FOR XML PATH('')
				)
			), 1, 1, '')) AS CC_TRADEMARK_STR,
			CC_COMMON_REQ_GOOD,
			REVERSE(STUFF(REVERSE(
				(
					SELECT GR_SHORT + CHAR(10)
					FROM
						Purchase.GoodRequirement
						INNER JOIN Purchase.ClientConditionGoodRequirement ON CCGR_ID_GR = GR_ID
					WHERE CCGR_ID_CC = CC_ID
					ORDER BY GR_SHORT FOR XML PATH('')
				)
			), 1, 1, '')) AS CC_COMMON_REQ_GOOD_STR,
			CC_COMMON_REQ_PARTNER,
			REVERSE(STUFF(REVERSE(
				(
					SELECT PR_SHORT + CHAR(10)
					FROM
						Purchase.PartnerRequirement
						INNER JOIN Purchase.ClientConditionPartnerRequirement ON CCPR_ID_PR = PR_ID
					WHERE CCPR_ID_CC = CC_ID
					ORDER BY PR_SHORT FOR XML PATH('')
				)
			), 1, 1, '')) AS CC_COMMON_REQ_PARTNER_STR,
			CC_VALIDATION_PRICE,
			REVERSE(STUFF(REVERSE(
				(
					SELECT PV_SHORT + CHAR(10)
					FROM
						Purchase.PriceValidation
						INNER JOIN Purchase.ClientConditionPriceValidation ON CCPV_ID_PV = PV_ID
					WHERE CCPV_ID_CC = CC_ID
					ORDER BY PV_SHORT FOR XML PATH('')
				)
			), 1, 1, '')) AS CC_VALIDATION_PRICE_STR,
			PO_ID, PO_NAME, PO_NUM,
			CPO_USE_CONDITION, CPO_USE_CONDITION_STR,
			CPO_CLAIM_CANCEL_REASON, CPO_CLAIM_CANCEL_REASON_STR,
			CPO_CLAIM_PROVISION, CPO_CLAIM_PROVISION_STR,
			CPO_CONTRACT_PROVISION, CPO_CONTRACT_PROVISION_STR,
			CPO_DOCUMENT, CPO_DOCUMENT_STR,
			CPO_OTHER_PROVISION, CPO_OTHER_PROVISION_STR
		FROM
			Purchase.ClientConditionCard
			INNER JOIN dbo.ClientTable ON CC_ID_CLIENT = CLientID
			INNER JOIN dbo.Lawyer ON LW_ID = CC_ID_LAWYER
			LEFT OUTER JOIN
				(
					SELECT
						PO_ID, PO_NAME, PO_NUM,
						CPO_USE_CONDITION,
						REVERSE(STUFF(REVERSE(
							(
								SELECT UC_SHORT + CHAR(10)
								FROM
									Purchase.UseCondition
									INNER JOIN Purchase.ClientConditionPlacementOrderUseCondition ON UC_ID = ID_UC
								WHERE ID_CPO = CPO_ID
								ORDER BY UC_SHORT FOR XML PATH('')
							)
						), 1, 1, '')) AS CPO_USE_CONDITION_STR,
						CPO_CLAIM_CANCEL_REASON,
						REVERSE(STUFF(REVERSE(
							(
								SELECT CCR_SHORT + CHAR(10)
								FROM
									Purchase.ClaimCancelReason
									INNER JOIN Purchase.ClientConditionPlacementOrderClaimCancelReason ON CCR_ID = ID_CCR
								WHERE ID_CPO = CPO_ID
								ORDER BY CCR_SHORT FOR XML PATH('')
							)
						), 1, 1, '')) AS CPO_CLAIM_CANCEL_REASON_STR,
						CPO_CLAIM_PROVISION,
						REVERSE(STUFF(REVERSE(
							(
								SELECT CP_SHORT + CHAR(10)
								FROM
									Purchase.ClaimProvision
									INNER JOIN Purchase.ClientConditionPlacementOrderClaimProvision ON CP_ID = ID_CP
								WHERE ID_CPO = CPO_ID
								ORDER BY CP_SHORT FOR XML PATH('')
							)
						), 1, 1, '')) AS CPO_CLAIM_PROVISION_STR,
						CPO_CONTRACT_PROVISION,
						REVERSE(STUFF(REVERSE(
							(
								SELECT CEP_SHORT + CHAR(10)
								FROM
									Purchase.ContractExecutionProvision
									INNER JOIN Purchase.ClientConditionPlacementOrderContractExecutionProvision ON CEP_ID = ID_CEP
								WHERE ID_CPO = CPO_ID
								ORDER BY CEP_SHORT FOR XML PATH('')
							)
						), 1, 1, '')) AS CPO_CONTRACT_PROVISION_STR,
						CPO_DOCUMENT,
						REVERSE(STUFF(REVERSE(
							(
								SELECT DC_SHORT + CHAR(10)
								FROM
									Purchase.Document
									INNER JOIN Purchase.ClientConditionPlacementOrderDocument ON DC_ID = ID_DC
								WHERE ID_CPO = CPO_ID
								ORDER BY DC_SHORT FOR XML PATH('')
							)
						), 1, 1, '')) AS CPO_DOCUMENT_STR,
						CPO_OTHER_PROVISION,
						REVERSE(STUFF(REVERSE(
							(
								SELECT OP_SHORT + CHAR(10)
								FROM
									Purchase.OtherProvision
									INNER JOIN Purchase.ClientConditionPlacementOrderOtherProvision ON OP_ID = ID_OP
								WHERE ID_CPO = CPO_ID
								ORDER BY OP_SHORT FOR XML PATH('')
							)
						), 1, 1, '')) AS CPO_OTHER_PROVISION_STR
					FROM
						Purchase.ClientConditionPlacementOrder
						INNER JOIN Purchase.PlacementOrder ON CPO_ID_PO = PO_ID
					WHERE CPO_ID_CC = @ID
				) AS o_O ON 1 = 1
		WHERE CC_ID = @ID
		ORDER BY PO_NUM

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [Purchase].[CLIENT_CONDITION_PRINT] TO rl_condition_card_r;
GO
