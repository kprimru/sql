USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ClientSatisfactionQuestion]
(
        [CSQ_ID]            UniqueIdentifier      NOT NULL,
        [CSQ_ID_CS]         UniqueIdentifier      NOT NULL,
        [CSQ_ID_QUESTION]   UniqueIdentifier      NOT NULL,
        [CSQ_NOTE]          VarChar(500)          NOT NULL,
        CONSTRAINT [PK_dbo.ClientSatisfactionQuestion] PRIMARY KEY NONCLUSTERED ([CSQ_ID]),
        CONSTRAINT [FK_dbo.ClientSatisfactionQuestion(CSQ_ID_QUESTION)_dbo.SatisfactionQuestion(SQ_ID)] FOREIGN KEY  ([CSQ_ID_QUESTION]) REFERENCES [dbo].[SatisfactionQuestion] ([SQ_ID]),
        CONSTRAINT [FK_dbo.ClientSatisfactionQuestion(CSQ_ID_CS)_dbo.ClientSatisfaction(CS_ID)] FOREIGN KEY  ([CSQ_ID_CS]) REFERENCES [dbo].[ClientSatisfaction] ([CS_ID])
);
GO
CREATE UNIQUE CLUSTERED INDEX [UC_dbo.ClientSatisfactionQuestion(CSQ_ID_CS,CSQ_ID_QUESTION)] ON [dbo].[ClientSatisfactionQuestion] ([CSQ_ID_CS] ASC, [CSQ_ID_QUESTION] ASC);
GO
