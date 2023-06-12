USE [DocumentClaim]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Security].[Users]
(
        [ID]              UniqueIdentifier      NOT NULL,
        [CAPTION]         NVarChar(512)         NOT NULL,
        [NAME]            NVarChar(512)             NULL,
        [ID_DEPARTMENT]   UniqueIdentifier          NULL,
        [HEAD]            Bit                       NULL,
        [STATUS]          TinyInt               NOT NULL,
        [LAST]            DateTime              NOT NULL,
        CONSTRAINT [PK_Security.Users] PRIMARY KEY CLUSTERED ([ID])
);
GO
