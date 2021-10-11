USE [SaleDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Client].[RivalSystem]
(
        [ID]     UniqueIdentifier      NOT NULL,
        [NAME]   NVarChar(512)         NOT NULL,
        [GR]     NVarChar(512)             NULL,
        [ORD]    Int                       NULL,
        [LAST]   DateTime              NOT NULL,
        CONSTRAINT [PK_RivalSystem] PRIMARY KEY CLUSTERED ([ID])
);
GO
CREATE NONCLUSTERED INDEX [IX_LAST] ON [Client].[RivalSystem] ([LAST] ASC);
GO
