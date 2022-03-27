USE [BuhDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ContractSystemsTable]
(
        [ContractNumber]     Int               NOT NULL,
        [ProviderName]       VarChar(150)      NOT NULL,
        [ContractDate]       VarChar(30)       NOT NULL,
        [SystemNamePrefix]   VarChar(150)      NOT NULL,
        [SystemPrefix]       VarChar(20)           NULL,
        [SystemNameStr]      VarChar(250)      NOT NULL,
        [EdIzm]              VarChar(20)       NOT NULL,
        [SystemEdPrice]      Money             NOT NULL,
        [SystemPrice]        Money             NOT NULL,
        [MonthStr]           VarChar(50)       NOT NULL,
        [DistrType]          VarChar(100)      NOT NULL,
        [NetVersion]         VarChar(50)       NOT NULL,
        [SystemOrder]        Int               NOT NULL,
        [SystemSet]          Int               NOT NULL,
        [TaxPrice]           Money             NOT NULL,
        [TotalPrice]         Money             NOT NULL,
        [SystemNote]         VarChar(250)          NULL,
        [IsGenerated]        Bit                   NULL,
);
GO
CREATE CLUSTERED INDEX [IC_dbo.ContractSystemsTable(ContractNumber,ProviderName,ContractDate)] ON [dbo].[ContractSystemsTable] ([ContractNumber] ASC, [ProviderName] ASC, [ContractDate] ASC);
GO
GRANT DELETE ON [dbo].[ContractSystemsTable] TO DBAdministrator;
GRANT INSERT ON [dbo].[ContractSystemsTable] TO DBAdministrator;
GRANT SELECT ON [dbo].[ContractSystemsTable] TO DBAdministrator;
GRANT UPDATE ON [dbo].[ContractSystemsTable] TO DBAdministrator;
GRANT DELETE ON [dbo].[ContractSystemsTable] TO DBCount;
GRANT INSERT ON [dbo].[ContractSystemsTable] TO DBCount;
GRANT SELECT ON [dbo].[ContractSystemsTable] TO DBCount;
GRANT UPDATE ON [dbo].[ContractSystemsTable] TO DBCount;
GO
