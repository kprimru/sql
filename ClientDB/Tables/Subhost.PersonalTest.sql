USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Subhost].[PersonalTest]
(
        [ID]           UniqueIdentifier      NOT NULL,
        [ID_SUBHOST]   UniqueIdentifier      NOT NULL,
        [ID_TEST]      UniqueIdentifier      NOT NULL,
        [PERSONAL]     NVarChar(256)         NOT NULL,
        [START]        DateTime              NOT NULL,
        [FINISH]       DateTime                  NULL,
        CONSTRAINT [PK_Subhost.PersonalTest] PRIMARY KEY CLUSTERED ([ID])
);
GO
