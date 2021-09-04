USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[QuestionTable]
(
        [QuestionID]           Int             Identity(1,1)   NOT NULL,
        [QuestionName]         VarChar(50)                     NOT NULL,
        [QuestionDate]         SmallDateTime                   NOT NULL,
        [QuestionFreeAnswer]   Bit                             NOT NULL,
        CONSTRAINT [PK_dbo.QuestionTable] PRIMARY KEY CLUSTERED ([QuestionID])
);GO
