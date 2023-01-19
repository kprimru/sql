USE [SaleDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Price].[CommercialOfferOther]
(
        [ID]           UniqueIdentifier      NOT NULL,
        [ID_OFFER]     UniqueIdentifier      NOT NULL,
        [ID_SERVICE]   UniqueIdentifier      NOT NULL,
        [CNT]          SmallInt              NOT NULL,
        [ID_PERIOD]    UniqueIdentifier      NOT NULL,
        [ID_TAX]       UniqueIdentifier      NOT NULL,
        [PRICE]        Money                 NOT NULL,
        CONSTRAINT [PK_Price.CommercialOfferOther] PRIMARY KEY CLUSTERED ([ID])
);
GO
