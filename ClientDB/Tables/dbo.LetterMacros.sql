USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[LetterMacros]
(
        [ID]        UniqueIdentifier      NOT NULL,
        [NAME]      NVarChar(512)         NOT NULL,
        [CAPTION]   NVarChar(512)         NOT NULL,
        [FLD]       NVarChar(512)         NOT NULL,
        CONSTRAINT [PK_dbo.LetterMacros] PRIMARY KEY CLUSTERED ([ID])
);
GO
