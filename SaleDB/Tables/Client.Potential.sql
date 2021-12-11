USE [SaleDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Client].[Potential]
(
        [ID]     UniqueIdentifier      NOT NULL,
        [NAME]   NVarChar(512)         NOT NULL,
        [GR]     NVarChar(512)             NULL,
        [ORD]    Int                       NULL,
        [LAST]   DateTime              NOT NULL,
        CONSTRAINT [PK_Client.Potential] PRIMARY KEY CLUSTERED ([ID])
);
GO
CREATE NONCLUSTERED INDEX [IX_Client.Potential(LAST)] ON [Client].[Potential] ([LAST] ASC);
GO
