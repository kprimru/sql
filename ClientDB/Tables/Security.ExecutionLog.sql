USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Security].[ExecutionLog]
(
        [LG_ID]          bigint          Identity(1,1)   NOT NULL,
        [LG_SCHEMA]      NVarChar(256)                   NOT NULL,
        [LG_PROCEDURE]   NVarChar(512)                   NOT NULL,
        [LG_DATE]        DateTime                        NOT NULL,
        [LG_USER]        NVarChar(256)                   NOT NULL,
        [LG_HOST]        NVarChar(256)                   NOT NULL,
        CONSTRAINT [PK_Security.ExecutionLog] PRIMARY KEY CLUSTERED ([LG_ID])
);
GO
CREATE NONCLUSTERED INDEX [IX_Security.ExecutionLog(LG_PROCEDURE,LG_SCHEMA)] ON [Security].[ExecutionLog] ([LG_PROCEDURE] ASC, [LG_SCHEMA] ASC);
GO
