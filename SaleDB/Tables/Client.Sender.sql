USE [SaleDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Client].[Sender]
(
        [ID]     UniqueIdentifier      NOT NULL,
        [NAME]   NVarChar(512)         NOT NULL,
        [INDX]   SmallInt                  NULL,
        [LAST]   DateTime              NOT NULL,
        CONSTRAINT [PK_Client.Sender] PRIMARY KEY CLUSTERED ([ID])
);
GO
CREATE NONCLUSTERED INDEX [IX_Client.Sender(LAST)] ON [Client].[Sender] ([LAST] ASC);
GO
