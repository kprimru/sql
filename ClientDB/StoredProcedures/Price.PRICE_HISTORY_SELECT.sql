USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[Price].[PRICE_HISTORY_SELECT]', 'P ') IS NULL EXEC('CREATE PROCEDURE [Price].[PRICE_HISTORY_SELECT]  AS SELECT 1')
GO
CREATE OR ALTER PROCEDURE [Price].[PRICE_HISTORY_SELECT]
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

		SELECT b.NAME, a.PRICE
		FROM [Price].[System:Price]		AS a
		INNER JOIN [Common].[Period]	AS b ON a.DATE = b.START AND b.[TYPE] = 2
		WHERE A.[System_Id] = @SYSTEM
			AND B.START <= @START
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
