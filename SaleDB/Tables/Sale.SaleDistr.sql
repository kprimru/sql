USE [SaleDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Sale].[SaleDistr]
(
        [ID]          UniqueIdentifier      NOT NULL,
        [ID_SALE]     UniqueIdentifier      NOT NULL,
        [ID_SYSTEM]   UniqueIdentifier      NOT NULL,
        [ID_NET]      UniqueIdentifier      NOT NULL,
        [CNT]         TinyInt               NOT NULL,
        CONSTRAINT [PK_SaleDistr] PRIMARY KEY CLUSTERED ([ID]),
        CONSTRAINT [FK_SaleDistr_SaleCompany] FOREIGN KEY  ([ID_SALE]) REFERENCES [Sale].[SaleCompany] ([ID]),
        CONSTRAINT [FK_SaleDistr_Net] FOREIGN KEY  ([ID_NET]) REFERENCES [System].[Net] ([ID]),
        CONSTRAINT [FK_SaleDistr_Systems] FOREIGN KEY  ([ID_SYSTEM]) REFERENCES [System].[Systems] ([ID])
);GO
