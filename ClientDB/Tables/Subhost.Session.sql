USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Subhost].[Session]
(
        [ID]     UniqueIdentifier      NOT NULL,
        [DATE]   DateTime              NOT NULL,
        [LGN]    NVarChar(256)         NOT NULL,
        [IP]     NVarChar(256)         NOT NULL,
        CONSTRAINT [PK_Subhost.Session] PRIMARY KEY CLUSTERED ([ID])
);GO
