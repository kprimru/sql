USE [SaleDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [Price].[COMMERCIAL_OFFER_DETAIL_SAVE]
	@OFFER		UNIQUEIDENTIFIER,
	@OPERATION	UNIQUEIDENTIFIER,
	@VARIANT	SMALLINT,
	@PERIOD		UNIQUEIDENTIFIER,
	@MON_CNT	SMALLINT,
	@SYSTEM		UNIQUEIDENTIFIER,
	@OLD_SYSTEM	UNIQUEIDENTIFIER,
	@NEW_SYSTEM	UNIQUEIDENTIFIER,
	@NET		UNIQUEIDENTIFIER,
	@OLD_NET	UNIQUEIDENTIFIER,
	@NEW_NET	UNIQUEIDENTIFIER,
	@ACTION		UNIQUEIDENTIFIER,
	@TAX		UNIQUEIDENTIFIER,
	@DELIVERY_DISCOUNT	DECIMAL(6, 2),
	@SUPPORT_DISCOUNT	DECIMAL(6, 2),
	@FURTHER_DISCOUNT	DECIMAL(6, 2),
	@DELIVERY_INFLATION	DECIMAL(6, 2),
	@SUPPORT_INFLATION	DECIMAL(6, 2),
	@FURTHER_INFLATION	DECIMAL(6, 2),
	@DELIVERY_ORIGIN	MONEY,
	@DELIVERY_PRICE		MONEY,
	@SUPPORT_ORIGIN		MONEY,
	@SUPPORT_PRICE		MONEY,
	@SUPPORT_FURTHER	MONEY,
	@DEL_FREE			BIT = NULL,
	@OLD_SYSTEM_DISC	DECIMAL(6, 2) = NULL
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

	INSERT INTO Price.CommercialOfferDetail(ID_OFFER, ID_OPERATION, VARIANT, ID_PERIOD, MON_CNT, ID_SYSTEM, ID_OLD_SYSTEM, ID_NEW_SYSTEM, ID_NET, ID_OLD_NET, ID_NEW_NET, ID_ACTION, ID_TAX, DELIVERY_DISCOUNT, SUPPORT_DISCOUNT, FURTHER_DISCOUNT, DELIVERY_INFLATION, SUPPORT_INFLATION, FURTHER_INFLATION, DELIVERY_ORIGIN, DELIVERY_PRICE, SUPPORT_ORIGIN, SUPPORT_PRICE, SUPPORT_FURTHER, DEL_FREE, OLD_SYSTEM_DISCOUNT)
		VALUES(@OFFER, @OPERATION, @VARIANT, @PERIOD, @MON_CNT, @SYSTEM, @OLD_SYSTEM, @NEW_SYSTEM, @NET, @OLD_NET, @NEW_NET, @ACTION, @TAX, @DELIVERY_DISCOUNT, @SUPPORT_DISCOUNT, @FURTHER_DISCOUNT, @DELIVERY_INFLATION, @SUPPORT_INFLATION, @FURTHER_INFLATION, @DELIVERY_ORIGIN, @DELIVERY_PRICE, @SUPPORT_ORIGIN, @SUPPORT_PRICE, @SUPPORT_FURTHER, @DEL_FREE, @OLD_SYSTEM_DISC)
END
GO
GRANT EXECUTE ON [Price].[COMMERCIAL_OFFER_DETAIL_SAVE] TO rl_offer_w;
GO
