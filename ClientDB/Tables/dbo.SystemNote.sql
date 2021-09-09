USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[SystemNote]
(
        [ID]            UniqueIdentifier      NOT NULL,
        [ID_SYSTEM]     Int                   NOT NULL,
        [NOTE]          varbinary             NOT NULL,
        [NOTE_WTITLE]   varbinary                 NULL,
        CONSTRAINT [PK_dbo.SystemNote] PRIMARY KEY CLUSTERED ([ID]),
        CONSTRAINT [FK_dbo.SystemNote(ID_SYSTEM)_dbo.SystemTable(SystemID)] FOREIGN KEY  ([ID_SYSTEM]) REFERENCES [dbo].[SystemTable] ([SystemID])
);
GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_dbo.SystemNote(ID_SYSTEM)+(NOTE,NOTE_WTITLE)] ON [dbo].[SystemNote] ([ID_SYSTEM] ASC) INCLUDE ([NOTE], [NOTE_WTITLE]);
GO
