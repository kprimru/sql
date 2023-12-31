USE [SaleDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [Client].[DEPO_INFO_SELECT]
	@COMPANY_NUMBER		INT
AS
BEGIN
	SELECT
		di.NAME, di.INN, di.REGION, di.CITY, di.ADDRESS, di.FIO1,
		di.PHONE1, di.FIO2, di.PHONE2, di.RIVAL, ISNULL(dn.DEPO_NUM,0) as DEPO_NUM, ISNULL(dn.STATUS, 0) as STATUS
	FROM
		Client.DEPOInfo di
		LEFT OUTER JOIN Client.DepoNumbers dn ON di.COMPANY_NUMBER = dn.COMPANY_NUMBER
	WHERE
		di.COMPANY_NUMBER = @COMPANY_NUMBER

END

GO
GRANT EXECUTE ON [Client].[DEPO_INFO_SELECT] TO rl_depo_info_r;
GO
