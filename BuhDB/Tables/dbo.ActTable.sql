USE [BuhDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ActTable]
(
        [ActID]                 Int               NOT NULL,
        [ProviderName]          VarChar(150)      NOT NULL,
        [ProviderFullName]      VarChar(150)      NOT NULL,
        [ProviderCity]          VarChar(150)      NOT NULL,
        [ProviderDistributor]   VarChar(50)           NULL,
        [ActYear]               VarChar(50)       NOT NULL,
        [TaxName]               VarChar(150)      NOT NULL,
        [TaxRate]               VarChar(50)       NOT NULL,
        [TotalPrice]            Money             NOT NULL,
        [TotalTaxPrice]         Money             NOT NULL,
        [TotalStr]              VarChar(250)      NOT NULL,
        [ProviderDirector]      VarChar(250)      NOT NULL,
        [ProviderDirectorRod]   VarChar(250)      NOT NULL,
        [ActDate]               VarChar(10)       NOT NULL,
        [ActTime]               VarChar(50)       NOT NULL,
        [CustomerName]          VarChar(150)          NULL,
);
GO
CREATE NONCLUSTERED INDEX [IX_dbo.ActTable(ProviderName,ActDate)+(ActID,ActTime)] ON [dbo].[ActTable] ([ProviderName] ASC, [ActDate] ASC) INCLUDE ([ActID], [ActTime]);
CREATE NONCLUSTERED INDEX [IX_dbo.ActTable(ProviderName,ActDate,CustomerName)+(ActID,ActTime)] ON [dbo].[ActTable] ([ProviderName] ASC, [ActDate] ASC, [CustomerName] ASC) INCLUDE ([ActID], [ActTime]);
CREATE UNIQUE NONCLUSTERED INDEX [UX_dbo.ActTable(ActID)] ON [dbo].[ActTable] ([ActID] ASC);
GO
GRANT DELETE ON [dbo].[ActTable] TO DBAdministrator;
GRANT INSERT ON [dbo].[ActTable] TO DBAdministrator;
GRANT SELECT ON [dbo].[ActTable] TO DBAdministrator;
GRANT UPDATE ON [dbo].[ActTable] TO DBAdministrator;
GRANT DELETE ON [dbo].[ActTable] TO DBCount;
GRANT INSERT ON [dbo].[ActTable] TO DBCount;
GRANT SELECT ON [dbo].[ActTable] TO DBCount;
GRANT UPDATE ON [dbo].[ActTable] TO DBCount;
GO
