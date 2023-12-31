USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Report].[Reports:Templates]
(
        [Report_Id]      Int               NOT NULL,
        [Row:Index]      TinyInt           NOT NULL,
        [Type_Id]        TinyInt           NOT NULL,
        [TemplateName]   VarChar(128)      NOT NULL,
        [Params]         xml                   NULL,
        CONSTRAINT [PK_Report.Reports:Templates] PRIMARY KEY CLUSTERED ([Report_Id],[Row:Index])
);GO
