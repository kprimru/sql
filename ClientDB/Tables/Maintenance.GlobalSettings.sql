USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Maintenance].[GlobalSettings]
(
        [GS_ID]      UniqueIdentifier      NOT NULL,
        [GS_NAME]    VarChar(100)          NOT NULL,
        [GS_VALUE]   VarChar(500)              NULL,
        [GS_NOTE]    VarChar(Max)              NULL,
        [GS_LAST]    DateTime              NOT NULL,
        [Name]       VarChar(128)              NULL,
        [Value]      sql_variant               NULL,
        [Last]       DateTime                  NULL,
        CONSTRAINT [PK_Maintenance.GlobalSettings] PRIMARY KEY NONCLUSTERED ([GS_ID])
);
GO
CREATE UNIQUE CLUSTERED INDEX [UC_Maintenance.GlobalSettings(GS_NAME)] ON [Maintenance].[GlobalSettings] ([GS_NAME] ASC);
GO
