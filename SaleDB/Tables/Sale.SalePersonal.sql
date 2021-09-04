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
        CONSTRAINT [PK_SalePersonal] PRIMARY KEY CLUSTERED ([ID]),
        CONSTRAINT [FK_SalePersonal_SaleCompany] FOREIGN KEY  ([ID_SALE]) REFERENCES [Sale].[SaleCompany] ([ID]),
        CONSTRAINT [FK_SalePersonal_OfficePersonal] FOREIGN KEY  ([ID_PERSONAL]) REFERENCES [Personal].[OfficePersonal] ([ID])
);GO
