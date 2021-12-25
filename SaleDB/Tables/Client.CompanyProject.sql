USE [SaleDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Client].[CompanyProject]
(
        [ID]           UniqueIdentifier      NOT NULL,
        [ID_COMPANY]   UniqueIdentifier      NOT NULL,
        [ID_PROJECT]   UniqueIdentifier      NOT NULL,
        CONSTRAINT [PK_Client.CompanyProject] PRIMARY KEY CLUSTERED ([ID])
);
GO
CREATE NONCLUSTERED INDEX [IX_Client.CompanyProject(ID_COMPANY)+(ID_PROJECT)] ON [Client].[CompanyProject] ([ID_COMPANY] ASC) INCLUDE ([ID_PROJECT]);
GO
