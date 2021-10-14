USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Clients:Restrictions]
(
        [Id]          Int            Identity(1,1)   NOT NULL,
        [Client_Id]   Int                            NOT NULL,
        [Type_Id]     SmallInt                       NOT NULL,
        [Comment]     VarChar(Max)                       NULL,
        CONSTRAINT [PK_dbo.Clients:Restrictions] PRIMARY KEY NONCLUSTERED ([Id]),
        CONSTRAINT [FK_dbo.Clients:Restrictions(Client_Id)_dbo.ClientTable(ClientID)] FOREIGN KEY  ([Client_Id]) REFERENCES [dbo].[ClientTable] ([ClientID]),
        CONSTRAINT [FK_dbo.Clients:Restrictions(Type_Id)_dbo.Clients:Restrictions->Types(Id)] FOREIGN KEY  ([Type_Id]) REFERENCES [dbo].[Clients:Restrictions->Types] ([Id])
);
GO
CREATE UNIQUE NONCLUSTERED INDEX [UX_dbo.Clients:Restrictions(Client_Id,Type_Id)] ON [dbo].[Clients:Restrictions] ([Client_Id] ASC, [Type_Id] ASC);
GO
