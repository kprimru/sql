USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [USR].[ProcessJournal]
(
        [ID]            UniqueIdentifier      NOT NULL,
        [PR_DATE]       DateTime              NOT NULL,
        [PR_SPID]       SmallInt              NOT NULL,
        [PR_BEGIN]      DateTime              NOT NULL,
        [PR_END]        DateTime              NOT NULL,
        [PR_RES]        TinyInt               NOT NULL,
        [PR_TEXT]       NVarChar(Max)         NOT NULL,
        [PR_USER]       NVarChar(256)         NOT NULL,
        [PR_FILE]       VarChar(50)               NULL,
        [PR_COMPLECT]   VarChar(50)               NULL,
        CONSTRAINT [PK_USR.ProcessJournal] PRIMARY KEY CLUSTERED ([ID])
);
GO
CREATE NONCLUSTERED INDEX [IX_USR.ProcessJournal(PR_COMPLECT)+(PR_DATE,PR_BEGIN,PR_END,PR_TEXT,PR_USER)] ON [USR].[ProcessJournal] ([PR_COMPLECT] ASC) INCLUDE ([PR_DATE], [PR_BEGIN], [PR_END], [PR_TEXT], [PR_USER]);
GO
