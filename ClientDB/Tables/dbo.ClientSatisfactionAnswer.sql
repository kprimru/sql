USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ClientSatisfactionAnswer]
(
        [CSA_ID]            UniqueIdentifier      NOT NULL,
        [CSA_ID_QUESTION]   UniqueIdentifier      NOT NULL,
        [CSA_ID_ANSWER]     UniqueIdentifier      NOT NULL,
        CONSTRAINT [PK_dbo.ClientSatisfactionAnswer] PRIMARY KEY NONCLUSTERED ([CSA_ID]),
        CONSTRAINT [FK_dbo.ClientSatisfactionAnswer(CSA_ID_ANSWER)_dbo.SatisfactionAnswer(SA_ID)] FOREIGN KEY  ([CSA_ID_ANSWER]) REFERENCES [dbo].[SatisfactionAnswer] ([SA_ID]),
        CONSTRAINT [FK_dbo.ClientSatisfactionAnswer(CSA_ID_QUESTION)_dbo.ClientSatisfactionQuestion(CSQ_ID)] FOREIGN KEY  ([CSA_ID_QUESTION]) REFERENCES [dbo].[ClientSatisfactionQuestion] ([CSQ_ID])
);
GO
CREATE UNIQUE CLUSTERED INDEX [UC_dbo.ClientSatisfactionAnswer(CSA_ID_QUESTION,CSA_ID)] ON [dbo].[ClientSatisfactionAnswer] ([CSA_ID_QUESTION] ASC, [CSA_ID] ASC);
GO
