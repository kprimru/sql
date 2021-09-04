USE [SaleDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Client].[ManagerOdd]
(
        [Id]           UniqueIdentifier      NOT NULL,
        [Manager_Id]   UniqueIdentifier          NULL,
        [Host_Id]      SmallInt              NOT NULL,
        [Distr]        Int                   NOT NULL,
        [Comp]         TinyInt               NOT NULL,
        [UpdDate]      DateTime              NOT NULL,
        [UpdUser]      NVarChar(256)         NOT NULL,
        CONSTRAINT [PK__ManagerOdd__0623C4D8] PRIMARY KEY NONCLUSTERED ([Id])
);
GO
CREATE CLUSTERED INDEX [IX] ON [Client].[ManagerOdd] ([Distr] ASC, [Host_Id] ASC, [Comp] ASC);
GO
