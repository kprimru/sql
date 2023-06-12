USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ClientQuestionTable]
(
        [ClientQuestionID]               Int             Identity(1,1)   NOT NULL,
        [ClientID]                       Int                             NOT NULL,
        [QuestionID]                     Int                             NOT NULL,
        [AnswerID]                       Int                                 NULL,
        [ClientQuestionText]             VarChar(150)                        NULL,
        [ClientQuestionDate]             SmallDateTime                   NOT NULL,
        [ClientQuestionComment]          VarChar(Max)                        NULL,
        [ClientQuestionCreateDate]       DateTime                            NULL,
        [ClientQuestionCreateUser]       NVarChar(256)                       NULL,
        [ClientQuestionLastUpdate]       DateTime                            NULL,
        [ClientQuestionLastUpdateUser]   NVarChar(256)                       NULL,
        CONSTRAINT [PK_dbo.ClientQuestionTable] PRIMARY KEY CLUSTERED ([ClientQuestionID]),
        CONSTRAINT [FK_dbo.ClientQuestionTable(QuestionID)_dbo.QuestionTable(QuestionID)] FOREIGN KEY  ([QuestionID]) REFERENCES [dbo].[QuestionTable] ([QuestionID]),
        CONSTRAINT [FK_dbo.ClientQuestionTable(AnswerID)_dbo.AnswerTable(AnswerID)] FOREIGN KEY  ([AnswerID]) REFERENCES [dbo].[AnswerTable] ([AnswerID]),
        CONSTRAINT [FK_dbo.ClientQuestionTable(ClientID)_dbo.ClientTable(ClientID)] FOREIGN KEY  ([ClientID]) REFERENCES [dbo].[ClientTable] ([ClientID])
);
GO
CREATE NONCLUSTERED INDEX [IX_dbo.ClientQuestionTable(ClientID,QuestionID)+(ClientQuestionID)] ON [dbo].[ClientQuestionTable] ([ClientID] ASC, [QuestionID] ASC) INCLUDE ([ClientQuestionID]);
GO
