USE [BuhDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ContractTaxTable]
(
        [ContractNumber]   Int               NOT NULL,
        [ProviderName]     VarChar(150)      NOT NULL,
        [ContractDate]     VarChar(30)       NOT NULL,
        [TaxName]          VarChar(100)      NOT NULL,
        [TaxRate]          VarChar(50)       NOT NULL,
        [TaxPrice]         Money             NOT NULL,
);
GO
CREATE CLUSTERED INDEX [IC_dbo.ContractTaxTable(ContractNumber,ProviderName,ContractDate)] ON [dbo].[ContractTaxTable] ([ContractNumber] ASC, [ProviderName] ASC, [ContractDate] ASC);
GO
GRANT DELETE ON [dbo].[ContractTaxTable] TO DBAdministrator;
GRANT INSERT ON [dbo].[ContractTaxTable] TO DBAdministrator;
GRANT SELECT ON [dbo].[ContractTaxTable] TO DBAdministrator;
GRANT UPDATE ON [dbo].[ContractTaxTable] TO DBAdministrator;
GRANT DELETE ON [dbo].[ContractTaxTable] TO DBCount;
GRANT INSERT ON [dbo].[ContractTaxTable] TO DBCount;
GRANT SELECT ON [dbo].[ContractTaxTable] TO DBCount;
GRANT UPDATE ON [dbo].[ContractTaxTable] TO DBCount;
GO
