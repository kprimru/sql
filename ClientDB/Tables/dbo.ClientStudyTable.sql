USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ClientStudyTable]
(
        [ClientStudyID]   Int             Identity(1,1)   NOT NULL,
        [ClientID]        Int                             NOT NULL,
        [StudyDate]       SmallDateTime                   NOT NULL,
        [LessonPlaceID]   Int                                 NULL,
        [TeacherID]       Int                             NOT NULL,
        [OwnershipID]     Int                                 NULL,
        [SystemNeed]      VarChar(Max)                    NOT NULL,
        [Recomend]        VarChar(Max)                    NOT NULL,
        [StudyNote]       VarChar(Max)                    NOT NULL,
        [RepeatDate]      SmallDateTime                       NULL,
        [Teached]         Bit                                 NULL,
        CONSTRAINT [PK_dbo.ClientStudyTable] PRIMARY KEY NONCLUSTERED ([ClientStudyID]),
        CONSTRAINT [FK_dbo.ClientStudyTable(LessonPlaceID)_dbo.LessonPlaceTable(LessonPlaceID)] FOREIGN KEY  ([LessonPlaceID]) REFERENCES [dbo].[LessonPlaceTable] ([LessonPlaceID]),
        CONSTRAINT [FK_dbo.ClientStudyTable(TeacherID)_dbo.TeacherTable(TeacherID)] FOREIGN KEY  ([TeacherID]) REFERENCES [dbo].[TeacherTable] ([TeacherID]),
        CONSTRAINT [FK_dbo.ClientStudyTable(OwnershipID)_dbo.OwnershipTable(OwnershipID)] FOREIGN KEY  ([OwnershipID]) REFERENCES [dbo].[OwnershipTable] ([OwnershipID]),
        CONSTRAINT [FK_dbo.ClientStudyTable(ClientID)_dbo.ClientTable(ClientID)] FOREIGN KEY  ([ClientID]) REFERENCES [dbo].[ClientTable] ([ClientID])
);
GO
CREATE UNIQUE CLUSTERED INDEX [UC_dbo.ClientStudyTable(ClientID,ClientStudyID)] ON [dbo].[ClientStudyTable] ([ClientID] ASC, [ClientStudyID] ASC);
CREATE NONCLUSTERED INDEX [IX_dbo.ClientStudyTable(LessonPlaceID,StudyDate)+(ClientID)] ON [dbo].[ClientStudyTable] ([LessonPlaceID] ASC, [StudyDate] ASC) INCLUDE ([ClientID]);
CREATE NONCLUSTERED INDEX [IX_dbo.ClientStudyTable(RepeatDate)+(ClientStudyID,ClientID,StudyDate,TeacherID)] ON [dbo].[ClientStudyTable] ([RepeatDate] ASC) INCLUDE ([ClientStudyID], [ClientID], [StudyDate], [TeacherID]);
CREATE NONCLUSTERED INDEX [IX_dbo.ClientStudyTable(StudyDate)+(ClientStudyID,TeacherID)] ON [dbo].[ClientStudyTable] ([StudyDate] ASC) INCLUDE ([ClientStudyID], [TeacherID]);
GO
