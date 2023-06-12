USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ClientStudyPeople]
(
        [ID]             UniqueIdentifier      NOT NULL,
        [ID_STUDY]       UniqueIdentifier      NOT NULL,
        [SURNAME]        NVarChar(512)         NOT NULL,
        [NAME]           NVarChar(512)         NOT NULL,
        [PATRON]         NVarChar(512)         NOT NULL,
        [POSITION]       NVarChar(512)             NULL,
        [NUM]            SmallInt                  NULL,
        [GR_COUNT]       SmallInt                  NULL,
        [ID_SERT_TYPE]   UniqueIdentifier          NULL,
        [SERT_COUNT]     SmallInt                  NULL,
        [NOTE]           NVarChar(Max)             NULL,
        [ID_RDD_POS]     UniqueIdentifier          NULL,
        CONSTRAINT [PK_dbo.ClientStudyPeople] PRIMARY KEY CLUSTERED ([ID]),
        CONSTRAINT [FK_dbo.ClientStudyPeople(ID_STUDY)_dbo.ClientStudy(ID)] FOREIGN KEY  ([ID_STUDY]) REFERENCES [dbo].[ClientStudy] ([ID]),
        CONSTRAINT [FK_dbo.ClientStudyPeople(ID_SERT_TYPE)_dbo.SertificatType(ID)] FOREIGN KEY  ([ID_SERT_TYPE]) REFERENCES [dbo].[SertificatType] ([ID]),
        CONSTRAINT [FK_dbo.ClientStudyPeople(ID_RDD_POS)_dbo.RDDPosition(ID)] FOREIGN KEY  ([ID_RDD_POS]) REFERENCES [dbo].[RDDPosition] ([ID])
);
GO
CREATE NONCLUSTERED INDEX [IX_dbo.ClientStudyPeople(ID_STUDY)+(SURNAME,NAME,PATRON,POSITION,GR_COUNT,ID_SERT_TYPE)] ON [dbo].[ClientStudyPeople] ([ID_STUDY] ASC) INCLUDE ([SURNAME], [NAME], [PATRON], [POSITION], [GR_COUNT], [ID_SERT_TYPE]);
GO
