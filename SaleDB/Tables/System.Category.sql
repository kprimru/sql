USE [SaleDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [System].[Category]
(
        [ID]      UniqueIdentifier      NOT NULL,
        [NAME]    NVarChar(256)         NOT NULL,
        [SHORT]   NVarChar(128)         NOT NULL,
        [LAST]    DateTime              NOT NULL,
        CONSTRAINT [PK_Category] PRIMARY KEY CLUSTERED ([ID])
);
GO
CREATE NONCLUSTERED INDEX [IX_LAST] ON [System].[Category] ([LAST] ASC);
GO
