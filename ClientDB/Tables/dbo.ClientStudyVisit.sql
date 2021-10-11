USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ClientStudyVisit]
(
        [ID]           UniqueIdentifier      NOT NULL,
        [ID_MASTER]    UniqueIdentifier          NULL,
        [ID_CLIENT]    Int                   NOT NULL,
        [ID_TEACHER]   Int                   NOT NULL,
        [DATE]         SmallDateTime         NOT NULL,
        [NOTE]         NVarChar(Max)         NOT NULL,
        [STATUS]       TinyInt               NOT NULL,
        [UPD_DATE]     DateTime              NOT NULL,
        [UPD_USER]     NVarChar(256)         NOT NULL,
        CONSTRAINT [PK_dbo.ClientStudyVisit] PRIMARY KEY CLUSTERED ([ID]),
        CONSTRAINT [FK_dbo.ClientStudyVisit(ID_CLIENT)_dbo.ClientTable(ClientID)] FOREIGN KEY  ([ID_CLIENT]) REFERENCES [dbo].[ClientTable] ([ClientID]),
        CONSTRAINT [FK_dbo.ClientStudyVisit(ID_TEACHER)_dbo.TeacherTable(TeacherID)] FOREIGN KEY  ([ID_TEACHER]) REFERENCES [dbo].[TeacherTable] ([TeacherID])
);
GO
CREATE NONCLUSTERED INDEX [IX_dbo.ClientStudyVisit(ID_CLIENT)] ON [dbo].[ClientStudyVisit] ([ID_CLIENT] ASC);
GO
