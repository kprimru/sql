USE [FirstInstall]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Clients].[Clients]
(
        [CLMS_ID]     UniqueIdentifier      NOT NULL,
        [CLMS_LAST]   DateTime              NOT NULL,
        CONSTRAINT [PK_Clients_1] PRIMARY KEY CLUSTERED ([CLMS_ID])
);
GO
CREATE NONCLUSTERED INDEX [IX_CLMS_LAST] ON [Clients].[Clients] ([CLMS_LAST] DESC);
GO
