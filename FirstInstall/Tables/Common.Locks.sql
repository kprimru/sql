USE [FirstInstall]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Common].[Locks]
(
        [LC_ID]           UniqueIdentifier      NOT NULL,
        [LC_ID_DATA]      UniqueIdentifier      NOT NULL,
        [LC_RECORD]       UniqueIdentifier      NOT NULL,
        [LC_LOCK_TIME]    DateTime              NOT NULL,
        [LC_SPID]         Int                   NOT NULL,
        [LC_LOGIN]        VarChar(250)          NOT NULL,
        [LC_HOST]         VarChar(150)          NOT NULL,
        [LC_PROCESS]      VarChar(50)           NOT NULL,
        [LC_LOGIN_TIME]   DateTime              NOT NULL,
        [LC_NT_USER]      VarChar(150)          NOT NULL,
        CONSTRAINT [PK_Common.Locks] PRIMARY KEY CLUSTERED ([LC_ID])
);GO
