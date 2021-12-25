USE [BuhDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ContractTable]
(
        [ContractNumber]        Int               NOT NULL,
        [ContractDate]          VarChar(30)       NOT NULL,
        [ProviderName]          VarChar(250)      NOT NULL,
        [ProviderFullName]      VarChar(250)      NOT NULL,
        [ProviderAdress]        VarChar(250)      NOT NULL,
        [ProviderINN]           VarChar(100)      NOT NULL,
        [ProviderCalc]          VarChar(50)       NOT NULL,
        [ProviderCorrCount]     VarChar(50)       NOT NULL,
        [ProviderBank]          VarChar(150)      NOT NULL,
        [ProviderDirector]      VarChar(250)      NOT NULL,
        [ProviderDirectorRod]   VarChar(250)      NOT NULL,
        [ProviderBuh]           VarChar(100)      NOT NULL,
        [ProviderCity]          VarChar(150)      NOT NULL,
        [CustomerName]          VarChar(350)      NOT NULL,
        [CustomerAdress]        VarChar(250)          NULL,
        [CustomerUrAdress]      VarChar(250)          NULL,
        [CustomerBank]          VarChar(150)          NULL,
        [CustomerBik]           VarChar(100)          NULL,
        [CustomerINN]           VarChar(200)          NULL,
        [CustomerCalc]          VarChar(100)          NULL,
        [CustomerPurchaser]     VarChar(250)          NULL,
        [Sender]                VarChar(250)          NULL,
        [SenderAdress]          VarChar(200)          NULL,
        [Recieve]               VarChar(250)          NULL,
        [RecieveAdress]         VarChar(200)          NULL,
        [CountFounding]         VarChar(50)           NULL,
        [TotalSystemPrice]      Money             NOT NULL,
        [TotalPrice]            Money             NOT NULL,
        [TotalStr]              VarChar(200)      NOT NULL,
        [TemplateName]          VarChar(150)          NULL,
);
GO
CREATE NONCLUSTERED INDEX [IX_dbo.ContractTable(ContractDate,ProviderName,CustomerName)+(ContractNumber)] ON [dbo].[ContractTable] ([ContractDate] ASC, [ProviderName] ASC, [CustomerName] ASC) INCLUDE ([ContractNumber]);
CREATE NONCLUSTERED INDEX [IX_dbo.ContractTable(ProviderName,CustomerName)+(ContractNumber,ContractDate)] ON [dbo].[ContractTable] ([ProviderName] ASC, [CustomerName] ASC) INCLUDE ([ContractNumber], [ContractDate]);
CREATE UNIQUE NONCLUSTERED INDEX [UX_dbo.ContractTable(ContractNumber,ContractDate,ProviderName)] ON [dbo].[ContractTable] ([ContractNumber] ASC, [ContractDate] ASC, [ProviderName] ASC);
GO
GRANT DELETE ON [dbo].[ContractTable] TO DBAdministrator;
GRANT INSERT ON [dbo].[ContractTable] TO DBAdministrator;
GRANT SELECT ON [dbo].[ContractTable] TO DBAdministrator;
GRANT UPDATE ON [dbo].[ContractTable] TO DBAdministrator;
GRANT DELETE ON [dbo].[ContractTable] TO DBCount;
GRANT INSERT ON [dbo].[ContractTable] TO DBCount;
GRANT SELECT ON [dbo].[ContractTable] TO DBCount;
GRANT UPDATE ON [dbo].[ContractTable] TO DBCount;
GO
