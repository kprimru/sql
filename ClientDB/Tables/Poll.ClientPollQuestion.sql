USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Poll].[ClientPollQuestion]
(
        [ID]            UniqueIdentifier      NOT NULL,
        [ID_POLL]       UniqueIdentifier      NOT NULL,
        [ID_QUESTION]   UniqueIdentifier      NOT NULL,
        CONSTRAINT [PK_Poll.ClientPollQuestion] PRIMARY KEY CLUSTERED ([ID]),
        CONSTRAINT [FK_Poll.ClientPollQuestion(ID_QUESTION)_Poll.Question(ID)] FOREIGN KEY  ([ID_QUESTION]) REFERENCES [Poll].[Question] ([ID]),
        CONSTRAINT [FK_Poll.ClientPollQuestion(ID_POLL)_Poll.ClientPoll(ID)] FOREIGN KEY  ([ID_POLL]) REFERENCES [Poll].[ClientPoll] ([ID])
);
GO
CREATE NONCLUSTERED INDEX [IX_Poll.ClientPollQuestion(ID_POLL)+(ID,ID_QUESTION)] ON [Poll].[ClientPollQuestion] ([ID_POLL] ASC) INCLUDE ([ID], [ID_QUESTION]);
GO
