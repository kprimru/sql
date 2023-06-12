USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Subhost].[Feedback]
(
        [ID]      UniqueIdentifier      NOT NULL,
        [DATE]    DateTime              NOT NULL,
        [EMAIL]   NVarChar(512)         NOT NULL,
        [NOTE]    NVarChar(Max)         NOT NULL,
        CONSTRAINT [PK_Subhost.Feedback] PRIMARY KEY CLUSTERED ([ID])
);
GO
