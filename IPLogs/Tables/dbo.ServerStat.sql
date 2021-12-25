USE [IPLogs]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ServerStat]
(
        [SS_ID]        Int   Identity(1,1)   NOT NULL,
        [SS_ID_FILE]   Int                   NOT NULL,
        CONSTRAINT [PK_dbo.ServerStat] PRIMARY KEY CLUSTERED ([SS_ID]),
        CONSTRAINT [FK_dbo.ServerStat(SS_ID_FILE)_dbo.Files(FL_ID)] FOREIGN KEY  ([SS_ID_FILE]) REFERENCES [dbo].[Files] ([FL_ID])
);GO
