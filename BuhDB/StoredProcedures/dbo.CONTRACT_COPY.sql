USE [BuhDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[CONTRACT_COPY]
	@NUM		INT,
	@DATE		VARCHAR(30),
	@PROVIDER	VARCHAR(250)
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @NEW_NUM INT

	SELECT @NEW_NUM = MAX(ContractNumber) + 1
	FROM dbo.ContractTable
	WHERE DATEPART(YEAR, CONVERT(DATETIME, ContractDate, 112)) = DATEPART(YEAR, CONVERT(DATETIME, @DATE, 112))
		AND ProviderName = @PROVIDER

	INSERT INTO dbo.ContractTable(ContractNumber, ContractDate, ProviderName, ProviderFullName, ProviderAdress, ProviderINN, ProviderCalc, ProviderCorrCount, ProviderBank, ProviderDirector, ProviderDirectorRod, ProviderBuh, ProviderCity, CustomerName, CustomerAdress, CustomerUrAdress, CustomerBank, CustomerBik, CustomerINN, CustomerCalc, CustomerPurchaser, Sender, SenderAdress, Recieve, RecieveAdress, CountFounding, TotalSystemPrice, TotalPrice, TotalStr, TemplateName)
		SELECT @NEW_NUM, ContractDate, ProviderName, ProviderFullName, ProviderAdress, ProviderINN, ProviderCalc, ProviderCorrCount, ProviderBank, ProviderDirector, ProviderDirectorRod, ProviderBuh, ProviderCity, CustomerName, CustomerAdress, CustomerUrAdress, CustomerBank, CustomerBik, CustomerINN, CustomerCalc, CustomerPurchaser, Sender, SenderAdress, Recieve, RecieveAdress, CountFounding, TotalSystemPrice, TotalPrice, TotalStr, TemplateName
		FROM dbo.ContractTable WITH(NOLOCK)
		WHERE ContractNumber = @NUM
			AND ContractDate = @DATE
			AND ProviderName = @PROVIDER

	INSERT INTO dbo.ContractTaxTable(ContractNumber, ProviderName, ContractDate, TaxName, TaxRate, TaxPrice)
		SELECT @NEW_NUM, ProviderName, ContractDate, TaxName, TaxRate, TaxPrice
		FROM dbo.ContractTaxTable WITH(NOLOCK)
		WHERE ContractNumber = @NUM
			AND ContractDate = @DATE
			AND ProviderName = @PROVIDER

	INSERT INTO dbo.ContractSystemsTable(ContractNumber, ProviderName, ContractDate, SystemNamePrefix, SystemPrefix, SystemNameStr, EdIzm, SystemEdPrice, SystemPrice, MonthStr, DistrType, NetVersion, SystemOrder, SystemSet, TaxPrice, TotalPrice, SystemNote)
		SELECT @NEW_NUM, ProviderName, ContractDate, SystemNamePrefix, SystemPrefix, SystemNameStr, EdIzm, SystemEdPrice, SystemPrice, MonthStr, DistrType, NetVersion, SystemOrder, SystemSet, TaxPrice, TotalPrice, SystemNote
		FROM dbo.ContractSystemsTable WITH(NOLOCK)
		WHERE ContractNumber = @NUM
			AND ContractDate = @DATE
			AND ProviderName = @PROVIDER
END
GO
GRANT EXECUTE ON [dbo].[CONTRACT_COPY] TO DBCount;
GO
