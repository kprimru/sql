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
        CONSTRAINT [PK__Client=T__75A5D8F8CBA40FBF] PRIMARY KEY CLUSTERED ([Client_Id]),
        CONSTRAINT [FK_Client=Tech_ClientTable] FOREIGN KEY  ([Client_Id]) REFERENCES [dbo].[ClientTable] ([ClientID])
);
GO
