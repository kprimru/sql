USE [SaleDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Sale].[SalePersonal]
(
        [ID]            UniqueIdentifier      NOT NULL,
        [ID_SALE]       UniqueIdentifier      NOT NULL,
        [ID_PERSONAL]   UniqueIdentifier      NOT NULL,
        [VALUE]         SmallInt              NOT NULL,
        CONSTRAINT [PK_Sale.SalePersonal] PRIMARY KEY CLUSTERED ([ID]),
        CONSTRAINT [FK_Sale.SalePersonal(ID_SALE)_Sale.SaleCompany(ID)] FOREIGN KEY  ([ID_SALE]) REFERENCES [Sale].[SaleCompany] ([ID]),
        CONSTRAINT [FK_Sale.SalePersonal(ID_PERSONAL)_Sale.OfficePersonal(ID)] FOREIGN KEY  ([ID_PERSONAL]) REFERENCES [Personal].[OfficePersonal] ([ID])
);GO
