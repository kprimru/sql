USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Locks]
(
        [LC_ID]           UniqueIdentifier      NOT NULL,
        [LC_DATA]         VarChar(64)           NOT NULL,
        [LC_REC]          VarChar(512)              NULL,
        [LC_REC_STR]      VarChar(512)              NULL,
        [LC_TIME]         DateTime              NOT NULL,
        [LC_SPID]         Int                   NOT NULL,
        [LC_LOGIN]        NVarChar(256)         NOT NULL,
        [LC_HOST]         NVarChar(256)         NOT NULL,
        [LC_LOGIN_TIME]   DateTime              NOT NULL,
        [LC_NT_USER]      NVarChar(256)         NOT NULL,
        CONSTRAINT [PK_dbo.Locks] PRIMARY KEY CLUSTERED ([LC_ID])
);GO
