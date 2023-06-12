USE [SaleDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Client].[CompanyInn]
(
        [Id]           UniqueIdentifier      NOT NULL,
        [Company_Id]   UniqueIdentifier      NOT NULL,
        [Inn]          VarChar(100)          NOT NULL,
        [Note]         VarChar(Max)          NOT NULL,
        CONSTRAINT [PK_Client.CompanyInn] PRIMARY KEY NONCLUSTERED ([Id]),
        CONSTRAINT [FK_CLientCompany_Id] FOREIGN KEY  ([Company_Id]) REFERENCES [Client].[Company] ([ID])
);
GO
CREATE CLUSTERED INDEX [IX_Company_Id] ON [Client].[CompanyInn] ([Company_Id] ASC);
CREATE NONCLUSTERED INDEX [IX_INN] ON [Client].[CompanyInn] ([Inn] ASC);
GO
