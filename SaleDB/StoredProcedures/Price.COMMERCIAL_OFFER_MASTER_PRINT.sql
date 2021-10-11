USE [SaleDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [Price].[COMMERCIAL_OFFER_MASTER_PRINT]
	@ID	UNIQUEIDENTIFIER
WITH EXECUTE AS OWNER
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

	DECLARE @MASTER NVARCHAR(512)

	SELECT @MASTER = N'EXEC ' + MASTER_PROC + N' @ID'
	FROM
		Price.OfferTemplate a
		INNER JOIN Price.CommercialOffer b ON a.ID = b.ID_TEMPLATE
	WHERE b.ID = @ID

	EXEC sp_executesql @MASTER, N'@ID UNIQUEIDENTIFIER', @ID
END
GO
GRANT EXECUTE ON [Price].[COMMERCIAL_OFFER_MASTER_PRINT] TO rl_offer_r;
GO
