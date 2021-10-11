USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Poll].[ClientPollAnswer]
(
        [ID]            UniqueIdentifier      NOT NULL,
        [ID_QUESTION]   UniqueIdentifier      NOT NULL,
        [ID_ANSWER]     UniqueIdentifier          NULL,
        [INT_ANSWER]    Int                       NULL,
        [TEXT_ANSWER]   NVarChar(1024)            NULL,
        CONSTRAINT [PK_Poll.ClientPollAnswer] PRIMARY KEY CLUSTERED ([ID]),
        CONSTRAINT [FK_Poll.ClientPollAnswer(ID_ANSWER)_Poll.Answer(ID)] FOREIGN KEY  ([ID_ANSWER]) REFERENCES [Poll].[Answer] ([ID]),
        CONSTRAINT [FK_Poll.ClientPollAnswer(ID_QUESTION)_Poll.ClientPollQuestion(ID)] FOREIGN KEY  ([ID_QUESTION]) REFERENCES [Poll].[ClientPollQuestion] ([ID])
);
GO
CREATE NONCLUSTERED INDEX [IX_Poll.ClientPollAnswer(ID_ANSWER)+(ID_QUESTION)] ON [Poll].[ClientPollAnswer] ([ID_ANSWER] ASC) INCLUDE ([ID_QUESTION]);
CREATE NONCLUSTERED INDEX [IX_Poll.ClientPollAnswer(ID_QUESTION)+(ID,ID_ANSWER,INT_ANSWER,TEXT_ANSWER)] ON [Poll].[ClientPollAnswer] ([ID_QUESTION] ASC) INCLUDE ([ID], [ID_ANSWER], [INT_ANSWER], [TEXT_ANSWER]);
GO
