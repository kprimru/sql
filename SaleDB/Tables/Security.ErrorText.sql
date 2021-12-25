USE [SaleDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Security].[ErrorText]
(
        [ID]     UniqueIdentifier      NOT NULL,
        [DATE]   DateTime              NOT NULL,
        [HOST]   NVarChar(256)         NOT NULL,
        [TEXT]   NVarChar(Max)         NOT NULL,
        CONSTRAINT [PK_Security.ErrorText] PRIMARY KEY CLUSTERED ([ID])
);GO
