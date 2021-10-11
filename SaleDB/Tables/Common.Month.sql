USE [SaleDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Common].[Month]
(
        [ID]       UniqueIdentifier      NOT NULL,
        [DATE]     SmallDateTime             NULL,
        [NAME]     NVarChar(256)         NOT NULL,
        [ACTIVE]   Bit                   NOT NULL,
        [LAST]     DateTime              NOT NULL,
        CONSTRAINT [PK_Month] PRIMARY KEY CLUSTERED ([ID])
);
GO
CREATE NONCLUSTERED INDEX [IX_LAST] ON [Common].[Month] ([LAST] ASC);
GO
