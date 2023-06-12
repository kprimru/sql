USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Subhost].[PersonalTestAnswer]
(
        [ID]            UniqueIdentifier      NOT NULL,
        [ID_QUESTION]   UniqueIdentifier      NOT NULL,
        [ID_ANSWER]     UniqueIdentifier      NOT NULL,
        CONSTRAINT [PK_Subhost.PersonalTestAnswer] PRIMARY KEY CLUSTERED ([ID])
);
GO
