USE [IPLogs]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ClientStat]
(
        [CS_ID]        Int   Identity(1,1)   NOT NULL,
        [CS_ID_FILE]   Int                   NOT NULL,
        CONSTRAINT [PK_dbo.ClientStat] PRIMARY KEY CLUSTERED ([CS_ID]),
        CONSTRAINT [FK_dbo.ClientStat(CS_ID_FILE)_dbo.Files(FL_ID)] FOREIGN KEY  ([CS_ID_FILE]) REFERENCES [dbo].[Files] ([FL_ID])
);GO
