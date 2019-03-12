USE [ClientDB]
	GO
	SET ANSI_NULLS ON
	GO
	SET QUOTED_IDENTIFIER ON
	GO
	CREATE PROCEDURE [Purchase].[TRADE_SITE_DELETE]
	@ID	UNIQUEIDENTIFIER
AS
BEGIN
	SET NOCOUNT ON;

	DELETE
	FROM Purchase.ClientConditionTradeSite
	WHERE CTS_ID_TS = @ID

	DELETE
	FROM Purchase.TradeSite
	WHERE TS_ID = @ID
END