USE [SaleDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Client].[CompanyTaxing]
(
        [ID]           UniqueIdentifier      NOT NULL,
        [ID_COMPANY]   UniqueIdentifier      NOT NULL,
        [ID_TAXING]    UniqueIdentifier      NOT NULL,
        CONSTRAINT [PK_Client.CompanyTaxing] PRIMARY KEY CLUSTERED ([ID])
);
GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_Client.CompanyTaxing(ID_COMPANY)] ON [Client].[CompanyTaxing] ([ID_COMPANY] ASC, [ID_TAXING] ASC);
CREATE UNIQUE NONCLUSTERED INDEX [IX_Client.CompanyTaxing(ID_TAXING)] ON [Client].[CompanyTaxing] ([ID_TAXING] ASC, [ID_COMPANY] ASC);
GO
