USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[LetterTable]
(
        [LetterID]          Int            Identity(1,1)   NOT NULL,
        [LetterDirectory]   VarChar(100)                   NOT NULL,
        [LetterName]        VarChar(100)                   NOT NULL,
        [LetterData]        varbinary                      NOT NULL,
        CONSTRAINT [PK_dbo.LetterTable] PRIMARY KEY CLUSTERED ([LetterID])
);GO
