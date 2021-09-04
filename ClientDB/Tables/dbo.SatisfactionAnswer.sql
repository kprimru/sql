USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[SatisfactionAnswer]
(
        [SA_ID]            UniqueIdentifier      NOT NULL,
        [SA_ID_QUESTION]   UniqueIdentifier      NOT NULL,
        [SA_TEXT]          VarChar(500)          NOT NULL,
        [SA_ORDER]         SmallInt              NOT NULL,
        CONSTRAINT [PK_dbo.SatisfactionAnswer] PRIMARY KEY CLUSTERED ([SA_ID]),
        CONSTRAINT [FK_dbo.SatisfactionAnswer(SA_ID_QUESTION)_dbo.SatisfactionQuestion(SQ_ID)] FOREIGN KEY  ([SA_ID_QUESTION]) REFERENCES [dbo].[SatisfactionQuestion] ([SQ_ID])
);GO
