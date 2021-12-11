USE [SaleDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Claim].[Claims->Types]
(
        [Id]        TinyInt           NOT NULL,
        [Code]      VarChar(100)      NOT NULL,
        [Name]      VarChar(100)      NOT NULL,
        [UpdDate]   DateTime          NOT NULL,
        CONSTRAINT [PK_Claim.Claims->Types] PRIMARY KEY CLUSTERED ([Id])
);GO
