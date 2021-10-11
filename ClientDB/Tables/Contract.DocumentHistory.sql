USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Contract].[DocumentHistory]
(
        [ID]            UniqueIdentifier      NOT NULL,
        [ID_DOCUMENT]   UniqueIdentifier      NOT NULL,
        [ID_STATUS]     UniqueIdentifier      NOT NULL,
        [DATE]          DateTime              NOT NULL,
        [PERSONAL]      NVarChar(256)         NOT NULL,
        [NOTE]          NVarChar(Max)             NULL,
        CONSTRAINT [PK_Contract.DocumentHistory] PRIMARY KEY CLUSTERED ([ID])
);GO
