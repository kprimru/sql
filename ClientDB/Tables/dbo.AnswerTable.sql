USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[AnswerTable]
(
        [AnswerID]     Int            Identity(1,1)   NOT NULL,
        [QuestionID]   Int                            NOT NULL,
        [AnswerName]   VarChar(150)                   NOT NULL,
        CONSTRAINT [PK_dbo.AnswerTable] PRIMARY KEY CLUSTERED ([AnswerID]),
        CONSTRAINT [FK_dbo.AnswerTable(QuestionID)_dbo.QuestionTable(QuestionID)] FOREIGN KEY  ([QuestionID]) REFERENCES [dbo].[QuestionTable] ([QuestionID])
);GO
