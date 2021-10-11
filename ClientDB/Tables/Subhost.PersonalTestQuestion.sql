USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Subhost].[PersonalTestQuestion]
(
        [ID]            UniqueIdentifier      NOT NULL,
        [ID_TEST]       UniqueIdentifier      NOT NULL,
        [ID_QUESTION]   UniqueIdentifier      NOT NULL,
        [ORD]           SmallInt              NOT NULL,
        [ANS]           NVarChar(Max)             NULL,
        [STATUS]        TinyInt               NOT NULL,
        CONSTRAINT [PK_Subhost.PersonalTestQuestion] PRIMARY KEY CLUSTERED ([ID])
);
GO
CREATE NONCLUSTERED INDEX [IX_Subhost.PersonalTestQuestion(ID_TEST)] ON [Subhost].[PersonalTestQuestion] ([ID_TEST] ASC);
GO
