USE [SaleDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Client].[PayCategory]
(
        [ID]      UniqueIdentifier      NOT NULL,
        [NAME]    NVarChar(256)         NOT NULL,
        [SHORT]   NVarChar(128)         NOT NULL,
        [GR]      NVarChar(256)             NULL,
        [ORD]     Int                       NULL,
        [LAST]    DateTime              NOT NULL,
        CONSTRAINT [PK_Client.PayCategory] PRIMARY KEY CLUSTERED ([ID])
);
GO
CREATE NONCLUSTERED INDEX [IX_Client.PayCategory(LAST)] ON [Client].[PayCategory] ([LAST] ASC);
GO
