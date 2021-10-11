USE [SaleDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [System].[Systems]
(
        [ID]      UniqueIdentifier      NOT NULL,
        [NAME]    NVarChar(1024)        NOT NULL,
        [SHORT]   NVarChar(128)         NOT NULL,
        [REG]     NVarChar(128)         NOT NULL,
        [HOST]    NVarChar(128)             NULL,
        [ORD]     SmallInt                  NULL,
        [LAST]    DateTime              NOT NULL,
        CONSTRAINT [PK_Systems_1] PRIMARY KEY CLUSTERED ([ID])
);GO
