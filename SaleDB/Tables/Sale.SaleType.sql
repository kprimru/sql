USE [SaleDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Sale].[SaleType]
(
        [ID]     UniqueIdentifier      NOT NULL,
        [NAME]   NVarChar(512)         NOT NULL,
        [LAST]   DateTime              NOT NULL,
        CONSTRAINT [PK_Sale.SaleType] PRIMARY KEY CLUSTERED ([ID])
);GO
