USE [SaleDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [Price].[COMMERCIAL_OFFER_OTHER_SAVE]
	@OFFER		UNIQUEIDENTIFIER,
	@PERIOD		UNIQUEIDENTIFIER,
	@SERVICE	UNIQUEIDENTIFIER,
	@TAX		UNIQUEIDENTIFIER,
	@DELIVERY_PRICE		MONEY
AS
BEGIN
	SET NOCOUNT ON;

    DECLARE
        @DebugError     VarChar(512),
        @DebugContext   Xml,
        @Params         Xml;

    EXEC [Debug].[Execution@Start]
        @Proc_Id        = @@ProcId,
        @Params         = @Params,
        @DebugContext   = @DebugContext OUT

	INSERT INTO Price.CommercialOfferOther(ID_OFFER, ID_SERVICE, CNT, ID_PERIOD, ID_TAX, PRICE)
		VALUES(@OFFER, @SERVICE, 1, @PERIOD, @TAX, @DELIVERY_PRICE)
END

GO
GRANT EXECUTE ON [Price].[COMMERCIAL_OFFER_OTHER_SAVE] TO rl_offer_w;
GO