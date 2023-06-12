USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[StudyQuality]
(
        [ID]           UniqueIdentifier      NOT NULL,
        [ID_CLIENT]    Int                   NOT NULL,
        [DATE]         SmallDateTime         NOT NULL,
        [NOTE]         NVarChar(Max)         NOT NULL,
        [ID_TEACHER]   Int                   NOT NULL,
        [ID_TYPE]      UniqueIdentifier      NOT NULL,
        [WEIGHT]       decimal                   NULL,
        [SYS_LIST]     NVarChar(Max)             NULL,
        CONSTRAINT [PK_dbo.StudyQuality] PRIMARY KEY CLUSTERED ([ID]),
        CONSTRAINT [FK_dbo.StudyQuality(ID_CLIENT)_dbo.ClientTable(ClientID)] FOREIGN KEY  ([ID_CLIENT]) REFERENCES [dbo].[ClientTable] ([ClientID]),
        CONSTRAINT [FK_dbo.StudyQuality(ID_TEACHER)_dbo.TeacherTable(TeacherID)] FOREIGN KEY  ([ID_TEACHER]) REFERENCES [dbo].[TeacherTable] ([TeacherID]),
        CONSTRAINT [FK_dbo.StudyQuality(ID_TYPE)_dbo.StudyQualityType(ID)] FOREIGN KEY  ([ID_TYPE]) REFERENCES [dbo].[StudyQualityType] ([ID])
);
GO
CREATE NONCLUSTERED INDEX [IX_dbo.StudyQuality(ID_CLIENT)] ON [dbo].[StudyQuality] ([ID_CLIENT] ASC);
GO
