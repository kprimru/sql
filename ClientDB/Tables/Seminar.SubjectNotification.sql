USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Seminar].[SubjectNotification]
(
        [Id]           Int                Identity(1,1)   NOT NULL,
        [Subject_Id]   UniqueIdentifier                       NULL,
        [EMail]        VarChar(128)                           NULL,
        [Date]         date                                   NULL,
        CONSTRAINT [PK_Seminar.SubjectNotification] PRIMARY KEY CLUSTERED ([Id]),
        CONSTRAINT [FK_Seminar.SubjectNotification(Subject_Id)_Seminar.Subject(ID)] FOREIGN KEY  ([Subject_Id]) REFERENCES [Seminar].[Subject] ([ID])
);
GO
