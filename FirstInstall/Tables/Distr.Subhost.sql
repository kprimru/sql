USE [FirstInstall]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Distr].[Subhost]
(
        [ID]     UniqueIdentifier      NOT NULL,
        [NAME]   VarChar(150)          NOT NULL,
        [REG]    VarChar(50)           NOT NULL,
        [LAST]   DateTime              NOT NULL,
        CONSTRAINT [PK_Subhost] PRIMARY KEY CLUSTERED ([ID])
);GO
