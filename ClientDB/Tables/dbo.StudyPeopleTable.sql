USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[StudyPeopleTable]
(
        [StudyPeopleID]       Int            Identity(1,1)   NOT NULL,
        [ClientStudyID]       Int                            NOT NULL,
        [StudentFam]          VarChar(100)                   NOT NULL,
        [StudentName]         VarChar(100)                   NOT NULL,
        [StudentOtch]         VarChar(100)                   NOT NULL,
        [StudentPositionID]   Int                                NULL,
        [StudyNumber]         Int                            NOT NULL,
        [Sertificat]          VarChar(100)                   NOT NULL,
        [StudyPeopleCount]    TinyInt                            NULL,
        [Department]          VarChar(100)                       NULL,
        [Last]                DateTime                           NULL,
        [SertificatType]      Int                                NULL,
        [SertificatCount]     Int                                NULL,
        CONSTRAINT [PK_dbo.StudyPeopleTable] PRIMARY KEY NONCLUSTERED ([StudyPeopleID]),
        CONSTRAINT [FK_dbo.StudyPeopleTable(ClientStudyID)_dbo.ClientStudyTable(ClientStudyID)] FOREIGN KEY  ([ClientStudyID]) REFERENCES [dbo].[ClientStudyTable] ([ClientStudyID]),
        CONSTRAINT [FK_dbo.StudyPeopleTable(StudentPositionID)_dbo.StudentPositionTable(StudentPositionID)] FOREIGN KEY  ([StudentPositionID]) REFERENCES [dbo].[StudentPositionTable] ([StudentPositionID])
);
GO
CREATE UNIQUE CLUSTERED INDEX [UC_dbo.StudyPeopleTable(ClientStudyID,StudyPeopleID)] ON [dbo].[StudyPeopleTable] ([ClientStudyID] ASC, [StudyPeopleID] ASC);
CREATE NONCLUSTERED INDEX [IX_dbo.StudyPeopleTable(ClientStudyID,StudentFam,StudentName,StudentOtch)] ON [dbo].[StudyPeopleTable] ([ClientStudyID] ASC, [StudentFam] ASC, [StudentName] ASC, [StudentOtch] ASC);
GO
