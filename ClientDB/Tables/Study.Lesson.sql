USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Study].[Lesson]
(
        [ID]          UniqueIdentifier      NOT NULL,
        [ID_MASTER]   UniqueIdentifier          NULL,
        [DATE]        SmallDateTime         NOT NULL,
        [TEACHER]     NVarChar(256)         NOT NULL,
        [THEME]       NVarChar(1024)        NOT NULL,
        [NOTE]        NVarChar(Max)         NOT NULL,
        [STATUS]      TinyInt               NOT NULL,
        [UPD_DATE]    DateTime              NOT NULL,
        [UPD_USER]    NVarChar(256)         NOT NULL,
        CONSTRAINT [PK_Study.Lesson] PRIMARY KEY CLUSTERED ([ID])
);
GO
CREATE NONCLUSTERED INDEX [IX_Study.Lesson(STATUS)+(TEACHER)] ON [Study].[Lesson] ([STATUS] ASC) INCLUDE ([TEACHER]);
GO
