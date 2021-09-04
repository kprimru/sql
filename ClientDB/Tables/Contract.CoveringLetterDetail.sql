USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Contract].[CoveringLetterDetail]
(
        [ID]          UniqueIdentifier      NOT NULL,
        [ID_LETTER]   UniqueIdentifier      NOT NULL,
        [ID_FORM]     UniqueIdentifier      NOT NULL,
        CONSTRAINT [PK_Contract.CoveringLetterDetail] PRIMARY KEY CLUSTERED ([ID])
);GO
