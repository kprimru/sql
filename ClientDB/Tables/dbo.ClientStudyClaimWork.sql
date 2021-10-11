USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ClientStudyClaimWork]
(
        [ID]          UniqueIdentifier      NOT NULL,
        [ID_MASTER]   UniqueIdentifier          NULL,
        [ID_CLAIM]    UniqueIdentifier      NOT NULL,
        [TP]          TinyInt               NOT NULL,
        [DATE]        DateTime              NOT NULL,
        [NOTE]        NVarChar(Max)         NOT NULL,
        [TEACHER]     NVarChar(256)         NOT NULL,
        [STATUS]      TinyInt               NOT NULL,
        [UPD_DATE]    DateTime              NOT NULL,
        [UPD_USER]    NVarChar(256)         NOT NULL,
        CONSTRAINT [PK_dbo.ClientStudyClaimWork] PRIMARY KEY CLUSTERED ([ID]),
        CONSTRAINT [FK_dbo.ClientStudyClaimWork(ID_MASTER)_dbo.ClientStudyClaimWork(ID)] FOREIGN KEY  ([ID_MASTER]) REFERENCES [dbo].[ClientStudyClaimWork] ([ID]),
        CONSTRAINT [FK_dbo.ClientStudyClaimWork(ID_CLAIM)_dbo.ClientStudyClaim(ID)] FOREIGN KEY  ([ID_CLAIM]) REFERENCES [dbo].[ClientStudyClaim] ([ID])
);
GO
CREATE NONCLUSTERED INDEX [IX_dbo.ClientStudyClaimWork(ID_CLAIM,STATUS)+(ID,TP,DATE,NOTE,TEACHER)] ON [dbo].[ClientStudyClaimWork] ([ID_CLAIM] ASC, [STATUS] ASC) INCLUDE ([ID], [TP], [DATE], [NOTE], [TEACHER]);
CREATE NONCLUSTERED INDEX [IX_dbo.ClientStudyClaimWork(TP,STATUS)+(ID_CLAIM,DATE,TEACHER)] ON [dbo].[ClientStudyClaimWork] ([TP] ASC, [STATUS] ASC) INCLUDE ([ID_CLAIM], [DATE], [TEACHER]);
GO
