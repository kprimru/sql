USE [SaleDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Price].[OtherServicePrice]
(
        [ID]           UniqueIdentifier      NOT NULL,
        [ID_SERVICE]   UniqueIdentifier      NOT NULL,
        [ID_PERIOD]    UniqueIdentifier      NOT NULL,
        [PRICE]        Money                 NOT NULL,
        CONSTRAINT [PK_Price.OtherServicePrice] PRIMARY KEY CLUSTERED ([ID])
);GO
