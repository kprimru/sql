USE [SaleDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [Client].[COMPANY_DELIVERY_GET]
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

	SELECT FIO, POS, EMAIL, DATE, PLAN_DATE, OFFER, STATE
	FROM Client.CompanyDelivery
	WHERE ID = @ID
END

GO
GRANT EXECUTE ON [Client].[COMPANY_DELIVERY_GET] TO rl_delivery_r;
GO
