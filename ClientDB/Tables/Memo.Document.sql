USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Memo].[Document]
(
        [ID]     UniqueIdentifier      NOT NULL,
        [NAME]   NVarChar(1024)        NOT NULL,
        CONSTRAINT [PK_Memo.Document] PRIMARY KEY CLUSTERED ([ID])
);GO
