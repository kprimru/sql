USE [DocumentClaim]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Common].[Settings]
(
        [ID]          UniqueIdentifier      NOT NULL,
        [USER_NAME]   NVarChar(256)             NULL,
        [SETTINGS]    xml                   NOT NULL,
        [LAST]        DateTime              NOT NULL,
        CONSTRAINT [PK_Common.Settings] PRIMARY KEY CLUSTERED ([ID])
);GO
