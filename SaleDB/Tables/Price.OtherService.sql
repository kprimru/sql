USE [SaleDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Price].[OtherService]
(
        [ID]     UniqueIdentifier      NOT NULL,
        [NAME]   NVarChar(256)         NOT NULL,
        [ORD]    Int                   NOT NULL,
        CONSTRAINT [PK_OtherService] PRIMARY KEY CLUSTERED ([ID])
);GO
