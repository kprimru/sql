USE [SaleDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [System].[Net]
(
        [ID]       UniqueIdentifier      NOT NULL,
        [NAME]     NVarChar(256)         NOT NULL,
        [SHORT]    NVarChar(64)          NOT NULL,
        [COEF]     decimal                   NULL,
        [WEIGHT]   decimal                   NULL,
        [RND]      SmallInt                  NULL,
        [LAST]     DateTime              NOT NULL,
        CONSTRAINT [PK_Net] PRIMARY KEY CLUSTERED ([ID])
);
GO
CREATE NONCLUSTERED INDEX [IX_LAST] ON [System].[Net] ([LAST] ASC);
GO
