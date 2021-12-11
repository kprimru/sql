USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Report].[Reports:Filters->Types]
(
        [Id]     TinyInt           NOT NULL,
        [Code]   VarChar(128)      NOT NULL,
        CONSTRAINT [PK_Report.Reports:Filters->Types] PRIMARY KEY CLUSTERED ([Id])
);
GO
