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

	SELECT @NUM = ISNULL(MAX(NUMBER) + 1, 1)
	FROM Client.Company
	WHERE STATUS IN (1, 3)
END
GRANT EXECUTE ON [Client].[COMPANY_NUMBER_GET] TO rl_company_r;
GO