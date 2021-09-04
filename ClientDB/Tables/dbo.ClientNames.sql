USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ClientNames]
(
        [ID]          UniqueIdentifier      NOT NULL,
        [ID_CLIENT]   Int                   NOT NULL,
        [NAME]        VarChar(500)          NOT NULL,
        CONSTRAINT [PK_dbo.ClientNames] PRIMARY KEY NONCLUSTERED ([ID]),
        CONSTRAINT [FK_dbo.ClientNames(ID_CLIENT)_dbo.ClientTable(ClientID)] FOREIGN KEY  ([ID_CLIENT]) REFERENCES [dbo].[ClientTable] ([ClientID])
);
GO
CREATE CLUSTERED INDEX [IC_dbo.ClientNames(ID_CLIENT,NAME)] ON [dbo].[ClientNames] ([ID_CLIENT] ASC, [NAME] ASC);
CREATE NONCLUSTERED INDEX [IX_dbo.ClientNames(NAME)+(ID_CLIENT)] ON [dbo].[ClientNames] ([NAME] ASC) INCLUDE ([ID_CLIENT]);
GO
