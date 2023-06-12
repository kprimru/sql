USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Subhost].[TestAnswer]
(
        [ID]            UniqueIdentifier      NOT NULL,
        [ID_QUESTION]   UniqueIdentifier      NOT NULL,
        [ANS_TEXT]      NVarChar(1024)        NOT NULL,
        [CORRECT]       Bit                   NOT NULL,
        CONSTRAINT [PK_Subhost.TestAnswer] PRIMARY KEY CLUSTERED ([ID])
);
GO
