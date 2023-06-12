USE [SaleDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[Price].[OFFER_TEMPLATE_SELECT]', 'P ') IS NULL EXEC('CREATE PROCEDURE [Price].[OFFER_TEMPLATE_SELECT]  AS SELECT 1')
GO
ALTER PROCEDURE [Price].[OFFER_TEMPLATE_SELECT]
	@FILTER	NVARCHAR(100) = NULL
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

	SELECT ID, SHORT, FILE_NAME, DEMO_FILE
	FROM Price.OfferTemplate
	ORDER BY SHORT
END
GO
GRANT EXECUTE ON [Price].[OFFER_TEMPLATE_SELECT] TO rl_offer_r;
GO
