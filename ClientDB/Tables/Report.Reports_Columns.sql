USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Report].[Reports:Columns]
(
        [Report_Id]    Int               NOT NULL,
        [Row:Index]    TinyInt           NOT NULL,
        [ColumnName]   VarChar(128)      NOT NULL,
        [Params]       xml               NOT NULL,
        CONSTRAINT [PK_Report.Reports:Columns] PRIMARY KEY CLUSTERED ([Report_Id],[Row:Index])
);GO
