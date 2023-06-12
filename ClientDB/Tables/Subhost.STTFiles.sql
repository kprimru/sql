USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Subhost].[STTFiles]
(
        [ID]           UniqueIdentifier      NOT NULL,
        [ID_SUBHOST]   UniqueIdentifier      NOT NULL,
        [USR]          NVarChar(256)         NOT NULL,
        [DATE]         DateTime              NOT NULL,
        [BIN]          varbinary             NOT NULL,
        [PROCESS]      DateTime                  NULL,
        CONSTRAINT [PK_Subhost.STTFiles] PRIMARY KEY CLUSTERED ([ID])
);
GO
