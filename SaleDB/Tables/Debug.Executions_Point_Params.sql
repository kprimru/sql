USE [SaleDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Debug].[Executions:Point:Params]
(
        [Id]          bigint            NOT NULL,
        [Row:Index]   TinyInt           NOT NULL,
        [Name]        VarChar(100)      NOT NULL,
        [Value]       VarChar(Max)      NOT NULL,
        CONSTRAINT [PK_Debug.Executions:Point:Params] PRIMARY KEY CLUSTERED ([Id],[Row:Index])
);
GO
