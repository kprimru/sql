USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Report].[ExecutionLog]
(
        [ID]          bigint             Identity(1,1)   NOT NULL,
        [ID_REPORT]   UniqueIdentifier                   NOT NULL,
        [USR]         NVarChar(256)                      NOT NULL,
        [DATE]        DateTime                           NOT NULL,
        CONSTRAINT [PK_Report.ExecutionLog] PRIMARY KEY CLUSTERED ([ID])
);GO
