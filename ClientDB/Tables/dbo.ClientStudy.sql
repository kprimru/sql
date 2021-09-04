USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ClientStudy]
(
        [ID]           UniqueIdentifier      NOT NULL,
        [ID_MASTER]    UniqueIdentifier          NULL,
        [ID_CLIENT]    Int                   NOT NULL,
        [ID_CLAIM]     UniqueIdentifier          NULL,
        [DATE]         SmallDateTime         NOT NULL,
        [ID_PLACE]     Int                       NULL,
        [ID_TEACHER]   Int                       NULL,
        [NEED]         VarChar(Max)              NULL,
        [RECOMEND]     VarChar(Max)              NULL,
        [NOTE]         VarChar(Max)              NULL,
        [TEACHED]      Bit                       NULL,
        [STATUS]       TinyInt               NOT NULL,
        [UPD_DATE]     DateTime              NOT NULL,
        [UPD_USER]     NVarChar(256)         NOT NULL,
        [OLD_ID]       Int                       NULL,
        [ID_TYPE]      UniqueIdentifier          NULL,
        [RIVAL]        NVarChar(Max)             NULL,
        [AGREEMENT]    Bit                   NOT NULL,
        CONSTRAINT [PK_dbo.ClientStudy] PRIMARY KEY CLUSTERED ([ID]),
        CONSTRAINT [FK_dbo.ClientStudy(ID_MASTER)_dbo.ClientStudy(ID)] FOREIGN KEY  ([ID_MASTER]) REFERENCES [dbo].[ClientStudy] ([ID]),
        CONSTRAINT [FK_dbo.ClientStudy(ID_CLIENT)_dbo.ClientTable(ClientID)] FOREIGN KEY  ([ID_CLIENT]) REFERENCES [dbo].[ClientTable] ([ClientID]),
        CONSTRAINT [FK_dbo.ClientStudy(ID_CLAIM)_dbo.ClientStudyClaim(ID)] FOREIGN KEY  ([ID_CLAIM]) REFERENCES [dbo].[ClientStudyClaim] ([ID]),
        CONSTRAINT [FK_dbo.ClientStudy(ID_PLACE)_dbo.LessonPlaceTable(LessonPlaceID)] FOREIGN KEY  ([ID_PLACE]) REFERENCES [dbo].[LessonPlaceTable] ([LessonPlaceID]),
        CONSTRAINT [FK_dbo.ClientStudy(ID_TEACHER)_dbo.TeacherTable(TeacherID)] FOREIGN KEY  ([ID_TEACHER]) REFERENCES [dbo].[TeacherTable] ([TeacherID]),
        CONSTRAINT [FK_dbo.ClientStudy(ID_TYPE)_dbo.StudyType(ID)] FOREIGN KEY  ([ID_TYPE]) REFERENCES [dbo].[StudyType] ([ID])
);
GO
CREATE NONCLUSTERED INDEX [IX_dbo.ClientStudy(ID_CLIENT,STATUS,DATE)] ON [dbo].[ClientStudy] ([ID_CLIENT] ASC, [STATUS] ASC, [DATE] ASC) INCLUDE ([UPD_DATE]);
CREATE NONCLUSTERED INDEX [IX_dbo.ClientStudy(ID_PLACE,STATUS,DATE)+(ID_CLIENT)] ON [dbo].[ClientStudy] ([ID_PLACE] ASC, [STATUS] ASC, [DATE] ASC) INCLUDE ([ID_CLIENT]);
CREATE NONCLUSTERED INDEX [IX_dbo.ClientStudy(STATUS,DATE)+(ID_CLIENT)] ON [dbo].[ClientStudy] ([STATUS] ASC, [DATE] ASC) INCLUDE ([ID_CLIENT]);
CREATE NONCLUSTERED INDEX [IX_dbo.ClientStudy(TEACHED,STATUS,DATE,ID_PLACE)+(ID_CLIENT,ID_TEACHER)] ON [dbo].[ClientStudy] ([TEACHED] ASC, [STATUS] ASC, [DATE] ASC, [ID_PLACE] ASC) INCLUDE ([ID_CLIENT], [ID_TEACHER]);
CREATE NONCLUSTERED INDEX [IX_MASTER] ON [dbo].[ClientStudy] ([ID_MASTER] ASC, [UPD_DATE] ASC);
GO
