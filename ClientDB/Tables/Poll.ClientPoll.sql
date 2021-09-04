USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Poll].[ClientPoll]
(
        [ID]          UniqueIdentifier      NOT NULL,
        [ID_CLIENT]   Int                   NOT NULL,
        [ID_CALL]     UniqueIdentifier          NULL,
        [DATE]        SmallDateTime         NOT NULL,
        [ID_BLANK]    UniqueIdentifier      NOT NULL,
        [NOTE]        NVarChar(Max)         NOT NULL,
        CONSTRAINT [PK_Poll.ClientPoll] PRIMARY KEY CLUSTERED ([ID]),
        CONSTRAINT [FK_Poll.ClientPoll(ID_BLANK)_Poll.Blank(ID)] FOREIGN KEY  ([ID_BLANK]) REFERENCES [Poll].[Blank] ([ID]),
        CONSTRAINT [FK_Poll.ClientPoll(ID_CLIENT)_Poll.ClientTable(ClientID)] FOREIGN KEY  ([ID_CLIENT]) REFERENCES [dbo].[ClientTable] ([ClientID])
);
GO
CREATE NONCLUSTERED INDEX [IX_Poll.ClientPoll(ID_CALL)] ON [Poll].[ClientPoll] ([ID_CALL] ASC);
CREATE NONCLUSTERED INDEX [IX_Poll.ClientPoll(ID_CLIENT)] ON [Poll].[ClientPoll] ([ID_CLIENT] ASC);
GO
