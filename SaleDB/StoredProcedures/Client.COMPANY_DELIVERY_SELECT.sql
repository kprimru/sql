USE [SaleDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [Client].[COMPANY_DELIVERY_SELECT]
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

	SELECT ID, FIO, POS, EMAIL, DATE, PLAN_DATE, OFFER, CASE STATE WHEN 1 THEN '��������' WHEN 2 THEN '���� � ��������' ELSE '???' END AS STATE_STR, PERSONAL
	FROM Client.CompanyDelivery
	WHERE ID_COMPANY = @ID
	ORDER BY STATE
END

GO
GRANT EXECUTE ON [Client].[COMPANY_DELIVERY_SELECT] TO rl_delivery_r;
GO
