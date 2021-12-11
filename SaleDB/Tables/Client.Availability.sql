USE [SaleDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Client].[Availability]
(
        [ID]      UniqueIdentifier      NOT NULL,
        [NAME]    NVarChar(512)         NOT NULL,
        [GR]      NVarChar(512)             NULL,
        [ORD]     Int                       NULL,
        [COLOR]   Int                       NULL,
        [LAST]    DateTime              NOT NULL,
        CONSTRAINT [PK_Client.Availability] PRIMARY KEY CLUSTERED ([ID])
);
GO
CREATE NONCLUSTERED INDEX [IX_Client.Availability(LAST)] ON [Client].[Availability] ([LAST] ASC);
GO
