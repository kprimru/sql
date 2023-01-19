USE [SaleDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[Price].[COMMERCIAL_OFFER_GET]', 'P ') IS NULL EXEC('CREATE PROCEDURE [Price].[COMMERCIAL_OFFER_GET]  AS SELECT 1')
GO
ALTER PROCEDURE [Price].[COMMERCIAL_OFFER_GET]
	@ID	UNIQUEIDENTIFIER
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

	SELECT
		ID, FULL_NAME, ADDRESS, DIRECTOR, PER_SURNAME, PER_NAME, PER_PATRON, DIRECTOR_POS,
		DATE, NUM, NOTE,
		DISCOUNT, INFLATION, ID_TEMPLATE
	FROM Price.CommercialOffer
	WHERE ID = @ID
END
GO
GRANT EXECUTE ON [Price].[COMMERCIAL_OFFER_GET] TO rl_offer_w;
GO
