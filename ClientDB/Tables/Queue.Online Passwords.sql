USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Queue].[Online Passwords]
(
        [Id]                Int             Identity(1,1)   NOT NULL,
        [FileName]          NVarChar(512)                   NOT NULL,
        [CreateDateTime]    DateTime                        NOT NULL,
        [ProcessDateTime]   DateTime                            NULL,
        [Login]             VarChar(100)                        NULL,
        [Password]          VarChar(100)                        NULL,
        CONSTRAINT [PK__Online Passwords__4C78A835] PRIMARY KEY CLUSTERED ([Id])
);
GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_FILENAME] ON [Queue].[Online Passwords] ([FileName] ASC);
CREATE NONCLUSTERED INDEX [IX_PROCESS] ON [Queue].[Online Passwords] ([ProcessDateTime] ASC);
GO
