USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ClientError]
(
        [ID]          UniqueIdentifier      NOT NULL,
        [ID_MASTER]   UniqueIdentifier          NULL,
        [ID_CLIENT]   Int                   NOT NULL,
        [NOTE]        NVarChar(Max)         NOT NULL,
        [STATUS]      TinyInt               NOT NULL,
        [UPD_DATE]    DateTime              NOT NULL,
        [UPD_USER]    NVarChar(256)         NOT NULL,
        CONSTRAINT [PK_dbo.ClientError] PRIMARY KEY CLUSTERED ([ID]),
        CONSTRAINT [FK_dbo.ClientError(ID_MASTER)_dbo.ClientError(ID)] FOREIGN KEY  ([ID_MASTER]) REFERENCES [dbo].[ClientError] ([ID]),
        CONSTRAINT [FK_dbo.ClientError(ID_CLIENT)_dbo.ClientTable(ClientID)] FOREIGN KEY  ([ID_CLIENT]) REFERENCES [dbo].[ClientTable] ([ClientID])
);GO
