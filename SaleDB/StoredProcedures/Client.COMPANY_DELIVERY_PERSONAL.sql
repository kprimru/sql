USE [SaleDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[Client].[COMPANY_DELIVERY_PERSONAL]', 'P ') IS NULL EXEC('CREATE PROCEDURE [Client].[COMPANY_DELIVERY_PERSONAL]  AS SELECT 1')
GO
ALTER PROCEDURE [Client].[COMPANY_DELIVERY_PERSONAL]
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

	SELECT DISTINCT PERSONAL
	FROM Client.CompanyDelivery
	ORDER BY PERSONAL
END

GO
GRANT EXECUTE ON [Client].[COMPANY_DELIVERY_PERSONAL] TO rl_delivery_filter;
GO
