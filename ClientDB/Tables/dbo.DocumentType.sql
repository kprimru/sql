USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[DocumentType]
(
        [ID]     UniqueIdentifier      NOT NULL,
        [NAME]   NVarChar(256)         NOT NULL,
        CONSTRAINT [PK_dbo.DocumentType] PRIMARY KEY CLUSTERED ([ID])
);GO
