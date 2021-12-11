USE [SaleDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Client].[WorkState]
(
        [ID]             UniqueIdentifier      NOT NULL,
        [NAME]           NVarChar(512)         NOT NULL,
        [SALE_AUTO]      Bit                       NULL,
        [PHONE_AUTO]     Bit                       NULL,
        [ARCHIVE_AUTO]   Bit                       NULL,
        [GR]             NVarChar(512)             NULL,
        [ORD]            Int                       NULL,
        [LAST]           DateTime              NOT NULL,
        CONSTRAINT [PK_Client.WorkState] PRIMARY KEY CLUSTERED ([ID])
);
GO
CREATE NONCLUSTERED INDEX [IX_Client.WorkState(LAST)] ON [Client].[WorkState] ([LAST] ASC);
GO
