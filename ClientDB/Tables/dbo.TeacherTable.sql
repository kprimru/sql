USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[TeacherTable]
(
        [TeacherID]       Int            Identity(1,1)   NOT NULL,
        [TeacherName]     VarChar(250)                   NOT NULL,
        [TeacherLogin]    VarChar(100)                   NOT NULL,
        [TeacherReport]   Bit                            NOT NULL,
        [TeacherNorma]    decimal                            NULL,
        CONSTRAINT [PK_dbo.TeacherTable] PRIMARY KEY CLUSTERED ([TeacherID])
);
GO
CREATE UNIQUE NONCLUSTERED INDEX [UX_dbo.TeacherTable(TeacherName)] ON [dbo].[TeacherTable] ([TeacherName] ASC);
GO
