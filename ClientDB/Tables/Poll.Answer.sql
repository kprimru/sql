USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Poll].[Answer]
(
        [ID]            UniqueIdentifier      NOT NULL,
        [ID_QUESTION]   UniqueIdentifier      NOT NULL,
        [NAME]          NVarChar(1024)        NOT NULL,
        [ORD]           SmallInt              NOT NULL,
        CONSTRAINT [PK_Poll.Answer] PRIMARY KEY CLUSTERED ([ID]),
        CONSTRAINT [FK_Poll.Answer(ID_QUESTION)_Poll.Question(ID)] FOREIGN KEY  ([ID_QUESTION]) REFERENCES [Poll].[Question] ([ID])
);
GO
