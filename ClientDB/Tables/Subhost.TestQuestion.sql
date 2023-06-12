USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Subhost].[TestQuestion]
(
        [ID]            UniqueIdentifier      NOT NULL,
        [ID_TEST]       UniqueIdentifier      NOT NULL,
        [QST_TEXT]      NVarChar(1024)        NOT NULL,
        [FULL_ANSWER]   NVarChar(Max)         NOT NULL,
        [TP]            TinyInt               NOT NULL,
        CONSTRAINT [PK_Subhost.TestQuestion] PRIMARY KEY CLUSTERED ([ID])
);
GO
