USE [BuhDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[dbo].[BILL_MASTER_PRINT]', 'P ') IS NULL EXEC('CREATE PROCEDURE [dbo].[BILL_MASTER_PRINT]  AS SELECT 1')
GO
ALTER PROCEDURE [dbo].[BILL_MASTER_PRINT]
	@ContractNumber		Int,
	@ProviderName		VarChar(100),
	@ContractDate		VarChar(100)
AS
BEGIN
	SET NOCOUNT ON;

	SELECT
		a.ContractNumber, a.ContractDate, dbo.DateStrToBillStr(a.ContractDate) AS ContractDateStr,
		a.ProviderName, a.ProviderAdress, a.ProviderINN, a.ProviderCalc, a.ProviderCorrCount, a.ProviderDirector, a.ProviderBank, a.ProviderBuh,
		a.TotalStr, a.TotalPrice, a.CustomerPurchaser, a.CustomerName, a.CustomerAdress, a.CustomerBank, a.CustomerINN, a.CustomerCalc,
		a.CustomerUrAdress, a.CustomerBik, a.Sender, a.SenderAdress, a.Recieve, a.RecieveAdress, b.ProviderLogo,
		c.TaxName, c.TaxRate, c.TaxPrice, CASE c.TaxRate WHEN '0%' THEN '' ELSE '(' + c.TaxRate + ')' END AS TaxRateStr,
		CASE c.TaxRate WHEN '0%' THEN c.TaxName ELSE 'с ' + c.TaxName END AS TaxNameStr
	FROM ContractTable a WITH (NOLOCK)
	LEFT JOIN ProviderTable b ON a.ProviderName = b.ProviderName
	LEFT JOIN ContractTaxTable c WITH (NOLOCK) ON a.ContractNumber = c.ContractNumber AND a.ContractDate = c.ContractDate AND a.ProviderName = c.ProviderName
	WHERE	a.ContractNumber = @ContractNumber
		AND a.ProviderName = @ProviderName
		AND a.ContractDate LIKE @ContractDate
END
GO
GRANT EXECUTE ON [dbo].[BILL_MASTER_PRINT] TO DBCount;
GO
