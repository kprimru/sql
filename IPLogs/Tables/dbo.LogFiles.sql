USE [IPLogs]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[LogFiles]
(
        [LF_ID_FILE]   Int                NOT NULL,
        [LF_TEXT]      NVarChar(Max)      NOT NULL,
        [LF_SHORT]     NVarChar(256)          NULL,
        [LF_DATE]      DateTime               NULL,
        [LF_TYPE]      NVarChar(64)           NULL,
        [LF_SYS]       SmallInt               NULL,
        [LF_DISTR]     Int                    NULL,
        [LF_COMP]      TinyInt                NULL,
        CONSTRAINT [PK_dbo.LogFiles] PRIMARY KEY CLUSTERED ([LF_ID_FILE]),
        CONSTRAINT [FK_dbo.LogFiles(LF_ID_FILE)_dbo.Files(FL_ID)] FOREIGN KEY  ([LF_ID_FILE]) REFERENCES [dbo].[Files] ([FL_ID])
);
GO
CREATE NONCLUSTERED INDEX [IX_dbo.LogFiles(LF_DATE)] ON [dbo].[LogFiles] ([LF_DATE] ASC);
CREATE NONCLUSTERED INDEX [IX_dbo.LogFiles(LF_DISTR,LF_COMP,LF_SYS)+(LF_SHORT,LF_DATE,LF_TYPE)] ON [dbo].[LogFiles] ([LF_DISTR] ASC, [LF_COMP] ASC, [LF_SYS] ASC) INCLUDE ([LF_SHORT], [LF_DATE], [LF_TYPE]);
GO
