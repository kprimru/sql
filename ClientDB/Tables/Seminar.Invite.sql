USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Seminar].[Invite]
(
        [ID]            UniqueIdentifier      NOT NULL,
        [ID_PERSONAL]   UniqueIdentifier      NOT NULL,
        [DATE]          DateTime              NOT NULL,
        [BIN]           varbinary             NOT NULL,
        CONSTRAINT [PK_Seminar.Invite] PRIMARY KEY CLUSTERED ([ID]),
        CONSTRAINT [FK_Seminar.Invite(ID_PERSONAL)_Seminar.Personal(ID)] FOREIGN KEY  ([ID_PERSONAL]) REFERENCES [Seminar].[Personal] ([ID])
);
GO
