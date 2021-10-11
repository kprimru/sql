USE [SaleDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [System].[ServiceType]
(
        [ID]     UniqueIdentifier      NOT NULL,
        [NAME]   NVarChar(256)         NOT NULL,
        [LAST]   DateTime              NOT NULL,
        CONSTRAINT [PK_SyrviceType] PRIMARY KEY CLUSTERED ([ID])
);
GO
CREATE NONCLUSTERED INDEX [IX_LAST] ON [System].[ServiceType] ([LAST] ASC);
GO
