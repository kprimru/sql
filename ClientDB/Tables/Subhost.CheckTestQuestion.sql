USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Subhost].[CheckTestQuestion]
(
        [ID]            UniqueIdentifier      NOT NULL,
        [ID_TEST]       UniqueIdentifier      NOT NULL,
        [ID_QUESTION]   UniqueIdentifier      NOT NULL,
        [RESULT]        TinyInt                   NULL,
        [NOTE]          NVarChar(Max)         NOT NULL,
        CONSTRAINT [PK_Subhost.CheckTestQuestion] PRIMARY KEY CLUSTERED ([ID])
);GO
