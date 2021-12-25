USE [SaleDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [System].[SystemType]
(
        [ID]     UniqueIdentifier      NOT NULL,
        [NAME]   NVarChar(256)         NOT NULL,
        [LAST]   DateTime              NOT NULL,
        CONSTRAINT [PK_System.SystemType] PRIMARY KEY CLUSTERED ([ID])
);
GO
CREATE NONCLUSTERED INDEX [IX_System.SystemType(LAST)] ON [System].[SystemType] ([LAST] ASC);
GO
