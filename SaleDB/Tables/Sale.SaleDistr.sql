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
        CONSTRAINT [PK_Sale.SaleDistr] PRIMARY KEY CLUSTERED ([ID]),
        CONSTRAINT [FK_Sale.SaleDistr(ID_SALE)_Sale.SaleCompany(ID)] FOREIGN KEY  ([ID_SALE]) REFERENCES [Sale].[SaleCompany] ([ID]),
        CONSTRAINT [FK_Sale.SaleDistr(ID_NET)_Sale.Net(ID)] FOREIGN KEY  ([ID_NET]) REFERENCES [System].[Net] ([ID]),
        CONSTRAINT [FK_Sale.SaleDistr(ID_SYSTEM)_Sale.Systems(ID)] FOREIGN KEY  ([ID_SYSTEM]) REFERENCES [System].[Systems] ([ID])
);
GO
