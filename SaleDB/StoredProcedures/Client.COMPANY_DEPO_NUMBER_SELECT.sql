USE [SaleDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [Client].[COMPANY_DEPO_NUMBER_SELECT]
	@COMPANY_NUMBER	INT
AS
BEGIN
	SELECT
		DEPO_NUM
	FROM
		Client.DepoNumbers
	WHERE
		COMPANY_NUMBER = @COMPANY_NUMBER
END

GO
GRANT EXECUTE ON [Client].[COMPANY_DEPO_NUMBER_SELECT] TO rl_company_depo_num;
GO
