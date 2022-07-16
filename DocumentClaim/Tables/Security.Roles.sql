USE [DocumentClaim]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Security].[Roles]
(
        [ID]          UniqueIdentifier      NOT NULL,
        [ID_MASTER]   UniqueIdentifier          NULL,
        [CAPTION]     NVarChar(512)         NOT NULL,
        [NAME]        NVarChar(512)             NULL,
        [NOTE]        NVarChar(Max)             NULL,
        [LAST]        DateTime              NOT NULL,
        CONSTRAINT [PK_Security.Roles] PRIMARY KEY CLUSTERED ([ID])
);GO
