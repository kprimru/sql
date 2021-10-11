USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Task].[TaskStatus]
(
        [ID]        UniqueIdentifier      NOT NULL,
        [NAME]      NVarChar(256)         NOT NULL,
        [PSEDO]     NVarChar(64)          NOT NULL,
        [INT_VAL]   TinyInt               NOT NULL,
        CONSTRAINT [PK_Task.TaskStatus] PRIMARY KEY CLUSTERED ([ID])
);GO
