USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Maintenance].[Jobs]
(
        [ID]        bigint          Identity(1,1)   NOT NULL,
        [Type_Id]   SmallInt                        NOT NULL,
        [START]     DateTime                        NOT NULL,
        [FINISH]    DateTime                            NULL,
        [LGN]       NVarChar(256)                   NOT NULL,
        [HST]       NVarChar(256)                   NOT NULL,
        [ERR]       NVarChar(256)                       NULL,
        CONSTRAINT [PK_Maintenance.Jobs] PRIMARY KEY CLUSTERED ([ID]),
        CONSTRAINT [FK_Maintenance.Jobs(Type_Id)_Maintenance.JobType(Id)] FOREIGN KEY  ([Type_Id]) REFERENCES [Maintenance].[JobType] ([Id])
);
GO
CREATE NONCLUSTERED INDEX [IX_Maintenance.Jobs(START)] ON [Maintenance].[Jobs] ([START] ASC);
CREATE NONCLUSTERED INDEX [IX_Maintenance.Jobs(Type_Id,START)] ON [Maintenance].[Jobs] ([Type_Id] ASC, [START] ASC);
GO
