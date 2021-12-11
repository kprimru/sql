USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[Purchase].[CLIENT_CONDITION_MAIN_SELECT]', 'P ') IS NULL EXEC('CREATE PROCEDURE [Purchase].[CLIENT_CONDITION_MAIN_SELECT]  AS SELECT 1')
GO
ALTER PROCEDURE [Purchase].[CLIENT_CONDITION_MAIN_SELECT]
	@ID	INT
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

		SELECT
			CC_ID, CC_DATE_PUB, CC_DATE_UPDATE, CC_DATE_COMPOSE, CC_DATE_ACTUAL,
			REVERSE(STUFF(REVERSE((
				SELECT TS_NAME + ', '
				FROM
					Purchase.ClientConditionTradeSite
					INNER JOIN Purchase.TradeSite ON TS_ID = CTS_ID_TS
				WHERE CTS_ID_CC = CC_ID
				ORDER BY TS_NAME FOR XML PATH('')
			)), 1, 2, '')) AS TS_STRING,
			CC_ID_LAWYER,
			('<LIST>' +
				(
					SELECT '{' + CONVERT(VARCHAR(50), CCA_ID_AC) + '}' AS ITEM
					FROM Purchase.ClientConditionActivity
					WHERE CCA_ID_CC = CC_ID
					ORDER BY CCA_ID_AC FOR XML PATH('')
				)
			+ '</LIST>') AS CC_ACTIVITY_ID,
			('<LIST>' +
				(
					SELECT '{' + CONVERT(VARCHAR(50), CAR_ID_AR) + '}' AS ITEM
					FROM Purchase.ClientConditionApplyReason
					WHERE CAR_ID_CC = CC_ID
					ORDER BY CAR_ID_AR FOR XML PATH('')
				)
			+ '</LIST>') AS CC_APPLY_REASON_ID,
			CC_APPLY_REASON,
			('<LIST>' +
				(
					SELECT '{' + CONVERT(VARCHAR(50), CCR_ID_PR) + '}' AS ITEM
					FROM Purchase.ClientConditionReason
					WHERE CCR_ID_CC = CC_ID
					ORDER BY CCR_ID_PR FOR XML PATH('')
				)
			+ '</LIST>') AS CC_REASON_ID,
			CC_CLAUSE_EXISTS, CC_CLAUSE_LINK, CC_CLAUSE_CLIENT_LINK,
			CC_TRADEMARK,
			('<LIST>' +
				(
					SELECT '{' + CONVERT(VARCHAR(50), CCT_ID_TM) + '}' AS ITEM
					FROM Purchase.ClientConditionTrademark
					WHERE CCT_ID_CC = CC_ID
					ORDER BY CCT_ID_TM FOR XML PATH('')
				)
			+ '</LIST>') AS CC_TRADEMARK_ID,
			CC_COMMON_REQ_GOOD,
			('<LIST>' +
				(
					SELECT '{' + CONVERT(VARCHAR(50), CCGR_ID_GR) + '}' AS ITEM
					FROM Purchase.ClientConditionGoodRequirement
					WHERE CCGR_ID_CC = CC_ID
					ORDER BY CCGR_ID_GR FOR XML PATH('')
				)
			+ '</LIST>') AS CC_GOOD_REQ_ID,
			CC_COMMON_REQ_PARTNER,
			('<LIST>' +
				(
					SELECT '{' + CONVERT(VARCHAR(50), CCPR_ID_PR) + '}' AS ITEM
					FROM Purchase.ClientConditionPartnerRequirement
					WHERE CCPR_ID_CC = CC_ID
					ORDER BY CCPR_ID_PR FOR XML PATH('')
				)
			+ '</LIST>') AS CC_PARTNER_REQ_ID,
			CC_VALIDATION_PRICE,
			('<LIST>' +
				(
					SELECT '{' + CONVERT(VARCHAR(50), CCPV_ID_PV) + '}' AS ITEM
					FROM Purchase.ClientConditionPriceValidation
					WHERE CCPV_ID_CC = CC_ID
					ORDER BY CCPV_ID_PV FOR XML PATH('')
				)
			+ '</LIST>') AS CC_PRICE_VALID_ID,
			CONVERT(VARCHAR(20), CC_LAST_UPDATE, 104) + ' ' + CONVERT(VARCHAR(20), CC_LAST_UPDATE, 108) + '/' + CC_LAST_UPDATE_USER AS CC_LAST_DATA
		FROM Purchase.ClientConditionCard
		WHERE CC_ID_CLIENT = @ID
			AND CC_STATUS = 1

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [Purchase].[CLIENT_CONDITION_MAIN_SELECT] TO rl_condition_card_r;
GO
