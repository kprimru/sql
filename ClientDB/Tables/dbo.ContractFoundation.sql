USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ContractFoundation]
(
        [ID]     UniqueIdentifier      NOT NULL,
        [NAME]   NVarChar(256)         NOT NULL,
        [LAST]   DateTime              NOT NULL,
        CONSTRAINT [PK_dbo.ContractFoundation] PRIMARY KEY CLUSTERED ([ID])
);GO
