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
        CONSTRAINT [PK_Client.ManagerOdd] PRIMARY KEY NONCLUSTERED ([Id])
);
GO
CREATE CLUSTERED INDEX [IC_Client.ManagerOdd(Distr,Host_Id,Comp)] ON [Client].[ManagerOdd] ([Distr] ASC, [Host_Id] ASC, [Comp] ASC);
GO
