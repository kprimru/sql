USE [SaleDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Client].[CompanySelection]
(
        [ID]           UniqueIdentifier      NOT NULL,
        [ID_COMPANY]   UniqueIdentifier      NOT NULL,
        [USR_NAME]     NVarChar(256)         NOT NULL,
        CONSTRAINT [PK_CompanySelection] PRIMARY KEY CLUSTERED ([ID]),
        CONSTRAINT [FK_CompanySelection_Company] FOREIGN KEY  ([ID_COMPANY]) REFERENCES [Client].[Company] ([ID])
);
GO
CREATE NONCLUSTERED INDEX [IX_CompanySelection_USR_NAME] ON [Client].[CompanySelection] ([USR_NAME] ASC) INCLUDE ([ID], [ID_COMPANY]);
GO
