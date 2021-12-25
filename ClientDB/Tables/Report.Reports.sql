USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Report].[Reports]
(
        [ID]             UniqueIdentifier      NOT NULL,
        [ID_MASTER]      UniqueIdentifier          NULL,
        [NAME]           NVarChar(256)         NOT NULL,
        [SHORT]          NVarChar(128)             NULL,
        [NOTE]           NVarChar(Max)         NOT NULL,
        [REP_SCHEMA]     NVarChar(256)             NULL,
        [REP_PROC]       NVarChar(256)             NULL,
        [REP_TEMPLATE]   NVarChar(256)             NULL,
        CONSTRAINT [PK_Report.Reports] PRIMARY KEY CLUSTERED ([ID])
);
GO
