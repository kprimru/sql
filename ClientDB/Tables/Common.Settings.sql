USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Common].[Settings]
(
        [ID]         UniqueIdentifier      NOT NULL,
        [USR_NAME]   NVarChar(256)         NOT NULL,
        [SETTINGS]   xml                       NULL,
        [LAST]       DateTime              NOT NULL,
        CONSTRAINT [PK_Common.Settings] PRIMARY KEY CLUSTERED ([ID])
);GO
