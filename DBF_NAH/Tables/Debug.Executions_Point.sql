USE [DBF_NAH]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Debug].[Executions:Point]
(
        [Id]              bigint         Identity(1,1)   NOT NULL,
        [Execution_Id]    bigint                         NOT NULL,
        [Row:Index]       TinyInt                        NOT NULL,
        [StartDateTime]   DateTime                       NOT NULL,
        [Name]            VarChar(128)                   NOT NULL,
        CONSTRAINT [PK_Debug.Executions:Point] PRIMARY KEY CLUSTERED ([Execution_Id],[Row:Index])
);
GO
