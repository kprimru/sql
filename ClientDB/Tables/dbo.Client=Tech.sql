USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Client=Tech]
(
        [Client_Id]   Int               NOT NULL,
        [Note]        VarChar(Max)          NULL,
        CONSTRAINT [PK_dbo.Client=Tech] PRIMARY KEY CLUSTERED ([Client_Id]),
        CONSTRAINT [FK_dbo.Client=Tech(Client_Id)_dbo.ClientTable(ClientID)] FOREIGN KEY  ([Client_Id]) REFERENCES [dbo].[ClientTable] ([ClientID])
);
GO
