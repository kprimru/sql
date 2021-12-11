USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Subhost].[FilesDownload]
(
        [ID]           UniqueIdentifier      NOT NULL,
        [ID_SUBHOST]   UniqueIdentifier      NOT NULL,
        [USR]          NVarChar(256)         NOT NULL,
        [DATE]         DateTime              NOT NULL,
        [FTYPE]        NVarChar(128)         NOT NULL,
        CONSTRAINT [PK_Subhost.FilesDownload] PRIMARY KEY CLUSTERED ([ID])
);
GO
