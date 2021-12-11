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
        CONSTRAINT [PK_Queue.Online Passwords] PRIMARY KEY CLUSTERED ([Id])
);
GO
CREATE NONCLUSTERED INDEX [IX_Queue.Online Passwords(Login] ON [Queue].[Online Passwords] ([Login] ASC);
CREATE NONCLUSTERED INDEX [IX_Queue.Online Passwords(ProcessDateTime)] ON [Queue].[Online Passwords] ([ProcessDateTime] ASC);
CREATE UNIQUE NONCLUSTERED INDEX [UX_Queue.Online Passwords(FileName)] ON [Queue].[Online Passwords] ([FileName] ASC);
GO
