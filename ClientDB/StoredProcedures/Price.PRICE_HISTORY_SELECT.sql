USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [Price].[PRICE_HISTORY_SELECT]
	@SYSTEM	INT,
	@MONTH	UNIQUEIDENTIFIER
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE
		@DebugError		VarChar(512),
		@DebugContext	Xml,
		@Params			Xml;

	DECLARE @START SMALLDATETIME

	EXEC [Debug].[Execution@Start]
		@Proc_Id		= @@ProcId,
		@Params			= @Params,
		@DebugContext	= @DebugContext OUT

	BEGIN TRY

		SELECT @START = START
		FROM Common.Period
		WHERE ID = @MONTH

		SELECT NAME, PRICE
		FROM
			(
				SELECT START, NAME, PRICE, ROW_NUMBER() OVER(PARTITION BY PRICE ORDER BY START) AS RN
				FROM
					Price.SystemPrice a
					INNER JOIN Common.Period b ON a.ID_MONTH = b.ID
				WHERE ID_SYSTEM = @SYSTEM AND START <= @START
			) AS o_O
		WHERE RN = 1
		ORDER BY START DESC

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [Price].[PRICE_HISTORY_SELECT] TO rl_price_history;
GO