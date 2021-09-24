USE [SaleDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [Client].[COMPANY_NUMBER_GET]
	@NUM	INT = NULL OUTPUT
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

	SELECT @NUM = ISNULL(MAX(NUMBER) + 1, 1)
	FROM Client.Company
	WHERE STATUS IN (1, 3)
END
GO
GRANT EXECUTE ON [Client].[COMPANY_NUMBER_GET] TO rl_company_r;
GO
