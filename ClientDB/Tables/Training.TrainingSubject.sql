USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Training].[TrainingSubject]
(
        [TS_ID]     UniqueIdentifier      NOT NULL,
        [TS_NAME]   VarChar(150)          NOT NULL,
        CONSTRAINT [PK_Training.TrainingSubject] PRIMARY KEY CLUSTERED ([TS_ID])
);GO
