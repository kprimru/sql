USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Poll].[Blank]
(
        [ID]     UniqueIdentifier      NOT NULL,
        [NAME]   NVarChar(256)         NOT NULL,
        CONSTRAINT [PK_Poll.Blank] PRIMARY KEY CLUSTERED ([ID])
);GO
