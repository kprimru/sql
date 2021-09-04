USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Subhost].[Users]
(
        [ID]           UniqueIdentifier      NOT NULL,
        [NAME]         NVarChar(256)         NOT NULL,
        [PASS]         NVarChar(256)         NOT NULL,
        [ID_SUBHOST]   UniqueIdentifier      NOT NULL,
        [ROLES]        NVarChar(Max)             NULL,
        CONSTRAINT [PK_Subhost.Users] PRIMARY KEY CLUSTERED ([ID])
);
GO
CREATE UNIQUE NONCLUSTERED INDEX [UX_Subhost.Users(NAME)] ON [Subhost].[Users] ([NAME] ASC);
GO
