USE [SaleDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Client].[Taxing]
(
        [ID]     UniqueIdentifier      NOT NULL,
        [NAME]   NVarChar(512)         NOT NULL,
        [LAST]   DateTime              NOT NULL,
        CONSTRAINT [PK_Client.Taxing] PRIMARY KEY CLUSTERED ([ID])
);
GO
CREATE NONCLUSTERED INDEX [IX_Client.Taxing(LAST)] ON [Client].[Taxing] ([LAST] ASC);
GO
