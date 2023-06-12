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
        CONSTRAINT [PK_Client.CompanySelection] PRIMARY KEY CLUSTERED ([ID]),
        CONSTRAINT [FK_Client.CompanySelection(ID_COMPANY)_Client.Company(ID)] FOREIGN KEY  ([ID_COMPANY]) REFERENCES [Client].[Company] ([ID])
);
GO
CREATE NONCLUSTERED INDEX [IX_Client.CompanySelection(USR_NAME)+(ID,ID_COMPANY)] ON [Client].[CompanySelection] ([USR_NAME] ASC) INCLUDE ([ID], [ID_COMPANY]);
GO
