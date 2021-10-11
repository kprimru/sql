USE [SaleDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Claim].[Claims->Statuses]
(
        [Id]        TinyInt           NOT NULL,
        [Code]      VarChar(100)      NOT NULL,
        [Name]      VarChar(100)      NOT NULL,
        [Color]     Int                   NULL,
        [UpdDate]   DateTime          NOT NULL,
        CONSTRAINT [PK__Claims->Statuses__296D0115] PRIMARY KEY CLUSTERED ([Id])
);GO
