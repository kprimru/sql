USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Subhost].[CheckTest]
(
        [ID]        UniqueIdentifier      NOT NULL,
        [ID_TEST]   UniqueIdentifier      NOT NULL,
        [RESULT]    TinyInt                   NULL,
        [NOTE]      NVarChar(Max)         NOT NULL,
        CONSTRAINT [PK_Subhost.CheckTest] PRIMARY KEY CLUSTERED ([ID])
);
GO
