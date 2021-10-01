USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [Purchase].[TRADE_SITE_UPDATE]
	@ID		UNIQUEIDENTIFIER,
	@NAME	VARCHAR(4000),
	@URL	VARCHAR(250),
	@SHORT	VARCHAR(200)
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

		UPDATE Purchase.TradeSite
		SET TS_NAME		=	@NAME,
			TS_URL		=	@URL,
			TS_SHORT	=	@SHORT
		WHERE TS_ID = @ID

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [Purchase].[TRADE_SITE_UPDATE] TO rl_trade_site_u;
GO
