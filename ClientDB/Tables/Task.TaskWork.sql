USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Task].[TaskWork]
(
        [ID]        UniqueIdentifier      NOT NULL,
        [ID_TASK]   UniqueIdentifier      NOT NULL,
        [DATE]      DateTime              NOT NULL,
        [AUTHOR]    NVarChar(256)         NOT NULL,
        [NOTE]      NVarChar(Max)         NOT NULL,
        CONSTRAINT [PK_Task.TaskWork] PRIMARY KEY CLUSTERED ([ID]),
        CONSTRAINT [FK_Task.TaskWork(ID_TASK)_Task.Tasks(ID)] FOREIGN KEY  ([ID_TASK]) REFERENCES [Task].[Tasks] ([ID])
);
GO
