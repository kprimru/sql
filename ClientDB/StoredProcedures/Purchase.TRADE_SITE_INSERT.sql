USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [Purchase].[TRADE_SITE_INSERT]
	@NAME	VARCHAR(4000),
	@URL	VARCHAR(250),
	@SHORT	VARCHAR(200),
	@ID		UNIQUEIDENTIFIER = NULL OUTPUT
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

		DECLARE @TBL TABLE(ID UNIQUEIDENTIFIER)

		INSERT INTO Purchase.TradeSite(TS_NAME, TS_URL, TS_SHORT)
			OUTPUT inserted.TS_ID INTO @TBL
			VALUES(@NAME, @URL, @SHORT)

		SELECT @ID = ID
		FROM @TBL

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GRANT EXECUTE ON [Purchase].[TRADE_SITE_INSERT] TO rl_trade_site_i;
GO