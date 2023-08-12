USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[Purchase].[CLIENT_CONDITION_TRADE_SITE_SELECT]', 'P ') IS NULL EXEC('CREATE PROCEDURE [Purchase].[CLIENT_CONDITION_TRADE_SITE_SELECT]  AS SELECT 1')
GO
CREATE OR ALTER PROCEDURE [Purchase].[CLIENT_CONDITION_TRADE_SITE_SELECT]
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
			TS_ID, TS_NAME, TS_URL, TS_SHORT,
			CONVERT(BIT,
				ISNULL(
					(
						SELECT COUNT(*)
						FROM
							Purchase.ClientConditionCard
							INNER JOIN Purchase.ClientConditionTradeSite ON CC_ID = CTS_ID_CC
						WHERE CC_ID_CLIENT = @ID
							AND CC_STATUS = 1
							AND CTS_ID_TS = TS_ID
					), 0)
			) AS TS_CHECKED
		FROM Purchase.TradeSite
		ORDER BY TS_NAME

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [Purchase].[CLIENT_CONDITION_TRADE_SITE_SELECT] TO rl_condition_card_r;
GO
