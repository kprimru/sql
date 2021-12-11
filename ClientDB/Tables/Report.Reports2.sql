USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Report].[Reports2]
(
        [Id]                  Int            Identity(1,1)   NOT NULL,
        [Parent_Id]           Int                                NULL,
        [Name]                VarChar(128)                   NOT NULL,
        [ShortFileName]       VarChar(128)                       NULL,
        [Note]                VarChar(Max)                       NULL,
        [SQL]                 VarChar(Max)                       NULL,
        [AvailableRoleName]   VarChar(128)                       NULL,
        CONSTRAINT [PK_Report.Reports2] PRIMARY KEY CLUSTERED ([Id])
);
GO
