USE [FirstInstall]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Install].[InstallAct]
(
        [IAMS_ID]     UniqueIdentifier      NOT NULL,
        [IAMS_LAST]   DateTime              NOT NULL,
        CONSTRAINT [PK_InstallAct] PRIMARY KEY CLUSTERED ([IAMS_ID])
);GO
