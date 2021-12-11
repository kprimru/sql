USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Report].[Reports:Templates->Types]
(
        [Id]     TinyInt           NOT NULL,
        [Code]   VarChar(128)      NOT NULL,
        CONSTRAINT [PK_Report.Reports:Templates->Types] PRIMARY KEY CLUSTERED ([Id])
);
GO
