USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ClientJournal]
(
        [ID]           UniqueIdentifier      NOT NULL,
        [ID_MASTER]    UniqueIdentifier          NULL,
        [ID_CLIENT]    Int                   NOT NULL,
        [ID_JOURNAL]   UniqueIdentifier      NOT NULL,
        [START]        SmallDateTime             NULL,
        [FINISH]       SmallDateTime             NULL,
        [NOTE]         NVarChar(Max)         NOT NULL,
        [STATUS]       TinyInt               NOT NULL,
        [UPD_DATE]     DateTime              NOT NULL,
        [UPD_USER]     NVarChar(256)         NOT NULL,
        CONSTRAINT [PK_dbo.ClientJournal] PRIMARY KEY CLUSTERED ([ID]),
        CONSTRAINT [FK_dbo.ClientJournal(ID_MASTER)_dbo.ClientJournal(ID)] FOREIGN KEY  ([ID_MASTER]) REFERENCES [dbo].[ClientJournal] ([ID]),
        CONSTRAINT [FK_dbo.ClientJournal(ID_JOURNAL)_dbo.Journal(ID)] FOREIGN KEY  ([ID_JOURNAL]) REFERENCES [dbo].[Journal] ([ID]),
        CONSTRAINT [FK_dbo.ClientJournal(ID_CLIENT)_dbo.ClientTable(ClientID)] FOREIGN KEY  ([ID_CLIENT]) REFERENCES [dbo].[ClientTable] ([ClientID])
);
GO
