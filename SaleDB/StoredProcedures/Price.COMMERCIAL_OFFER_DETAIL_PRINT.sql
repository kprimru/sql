USE [SaleDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [Price].[COMMERCIAL_OFFER_DETAIL_PRINT]
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

	DECLARE @DETAIL NVARCHAR(512)

	SELECT @DETAIL = N'EXEC ' + DETAIL_1_PROC + N' @ID'
	FROM
		Price.OfferTemplate a
		INNER JOIN Price.CommercialOffer b ON a.ID = b.ID_TEMPLATE
	WHERE b.ID = @ID

	IF @DETAIL IS NOT NULL
		EXEC sp_executesql @DETAIL, N'@ID UNIQUEIDENTIFIER', @ID
	ELSE
		SELECT 1 AS FL
		WHERE 1 = 0
END
GO
GRANT EXECUTE ON [Price].[COMMERCIAL_OFFER_DETAIL_PRINT] TO rl_offer_r;
GO