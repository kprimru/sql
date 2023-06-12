USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[StudyType]
(
        [ID]      UniqueIdentifier      NOT NULL,
        [NAME]    NVarChar(256)         NOT NULL,
        [PSEDO]   NVarChar(64)          NOT NULL,
        CONSTRAINT [PK_dbo.StudyType] PRIMARY KEY CLUSTERED ([ID])
);
GO
