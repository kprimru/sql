USE [SaleDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Sale].[SaleCompany]
(
        [ID]            UniqueIdentifier      NOT NULL,
        [ID_MASTER]     UniqueIdentifier          NULL,
        [ID_COMPANY]    UniqueIdentifier      NOT NULL,
        [ID_OFFICE]     UniqueIdentifier          NULL,
        [DATE]          DateTime              NOT NULL,
        [CONFIRMED]     Bit                   NOT NULL,
        [ID_ASSIGNER]   UniqueIdentifier          NULL,
        [ID_RIVAL]      UniqueIdentifier          NULL,
        [STATUS]        TinyInt               NOT NULL,
        [BDATE]         DateTime              NOT NULL,
        [EDATE]         DateTime                  NULL,
        [UPD_USER]      NVarChar(256)         NOT NULL,
        CONSTRAINT [PK_Sale.SaleCompany] PRIMARY KEY CLUSTERED ([ID]),
        CONSTRAINT [FK_Sale.SaleCompany(ID_MASTER)_Sale.SaleCompany(ID)] FOREIGN KEY  ([ID_MASTER]) REFERENCES [Sale].[SaleCompany] ([ID]),
        CONSTRAINT [FK_Sale.SaleCompany(ID_COMPANY)_Sale.Company(ID)] FOREIGN KEY  ([ID_COMPANY]) REFERENCES [Client].[Company] ([ID]),
        CONSTRAINT [FK_Sale.SaleCompany(ID_ASSIGNER)_Sale.OfficePersonal(ID)] FOREIGN KEY  ([ID_ASSIGNER]) REFERENCES [Personal].[OfficePersonal] ([ID]),
        CONSTRAINT [FK_Sale.SaleCompany(ID_OFFICE)_Sale.Office(ID)] FOREIGN KEY  ([ID_OFFICE]) REFERENCES [Client].[Office] ([ID]),
        CONSTRAINT [FK_Sale.SaleCompany(ID_RIVAL)_Sale.RivalSystem(ID)] FOREIGN KEY  ([ID_RIVAL]) REFERENCES [Client].[RivalSystem] ([ID])
);GO
