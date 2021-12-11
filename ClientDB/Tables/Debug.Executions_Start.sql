USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Debug].[Executions:Start]
(
        [Id]              bigint         Identity(1,1)   NOT NULL,
        [StartDateTime]   DateTime                       NOT NULL,
        [Object]          VarChar(512)                   NOT NULL,
        [UserName]        VarChar(128)                   NOT NULL,
        [HostName]        VarChar(128)                   NOT NULL,
        CONSTRAINT [PK_Debug.Executions:Start] PRIMARY KEY CLUSTERED ([Id])
);
GO
