USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ClientDutyQuestion]
(
        [ID]        UniqueIdentifier      NOT NULL,
        [SYS]       SmallInt              NOT NULL,
        [DISTR]     Int                   NOT NULL,
        [COMP]      TinyInt               NOT NULL,
        [DATE]      DateTime              NOT NULL,
        [FIO]       NVarChar(512)         NOT NULL,
        [EMAIL]     NVarChar(256)         NOT NULL,
        [PHONE]     NVarChar(256)         NOT NULL,
        [QUEST]     NVarChar(Max)         NOT NULL,
        [IMPORT]    DateTime                  NULL,
        [SUBHOST]   DateTime                  NULL,
        CONSTRAINT [PK_dbo.ClientDutyQuestion] PRIMARY KEY CLUSTERED ([ID])
);
GO
CREATE NONCLUSTERED INDEX [IX_dbo.ClientDutyQuestion(DATE,IMPORT)+(SYS,DISTR,COMP,FIO,EMAIL,PHONE,QUEST,ID,SUBHOST)] ON [dbo].[ClientDutyQuestion] ([DATE] ASC, [IMPORT] ASC) INCLUDE ([SYS], [DISTR], [COMP], [FIO], [EMAIL], [PHONE], [QUEST], [ID], [SUBHOST]);
CREATE NONCLUSTERED INDEX [IX_dbo.ClientDutyQuestion(DISTR,DATE,SYS,COMP)+(FIO,EMAIL,PHONE,QUEST)] ON [dbo].[ClientDutyQuestion] ([DISTR] ASC, [DATE] ASC, [SYS] ASC, [COMP] ASC) INCLUDE ([FIO], [EMAIL], [PHONE], [QUEST]);
CREATE NONCLUSTERED INDEX [IX_dbo.ClientDutyQuestion(IMPORT,DATE)] ON [dbo].[ClientDutyQuestion] ([IMPORT] ASC, [DATE] ASC);
CREATE NONCLUSTERED INDEX [IX_dbo.ClientDutyQuestion(SUBHOST,SYS,DISTR,COMP)] ON [dbo].[ClientDutyQuestion] ([SUBHOST] ASC, [SYS] ASC, [DISTR] ASC, [COMP] ASC);
GO
