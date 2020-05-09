USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [Purchase].[CLIENT_CONDITION_REASON_SELECT]
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
			PR_ID, PR_NAME,
			CONVERT(BIT,
				ISNULL(
					(
						SELECT COUNT(*)
						FROM
							Purchase.ClientConditionCard
							INNER JOIN Purchase.ClientConditionReason ON CC_ID = CCR_ID_CC
						WHERE CC_ID_CLIENT = @ID
							AND CC_STATUS = 1
							AND CCR_ID_PR = PR_ID
					), 0)
			) AS PR_CHECKED
		FROM Purchase.PurchaseReason
		ORDER BY PR_NUM

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [Purchase].[CLIENT_CONDITION_REASON_SELECT] TO rl_condition_card_r;
GO