USE [SaleDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [Price].[OFFER_TEMPLATE_LAST]
	@LAST	DATETIME = NULL OUTPUT
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

	SELECT @LAST = MAX(LAST)
	FROM Price.OfferTemplate
END
GO
GRANT EXECUTE ON [Price].[OFFER_TEMPLATE_LAST] TO rl_offer_r;
GO