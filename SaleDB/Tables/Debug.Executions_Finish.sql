USE [SaleDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Debug].[Executions:Finish]
(
        [Id]               bigint            NOT NULL,
        [FinishDateTime]   DateTime          NOT NULL,
        [Error]            VarChar(512)          NULL,
        CONSTRAINT [PK_Debug.Executions:Finish] PRIMARY KEY CLUSTERED ([Id])
);
GO
