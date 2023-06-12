USE [DocumentClaim]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Document].[DocumentStage]
(
        [ID]            UniqueIdentifier      NOT NULL,
        [ID_DOCUMENT]   UniqueIdentifier      NOT NULL,
        [ID_STAGE]      UniqueIdentifier      NOT NULL,
        [DATE]          DateTime              NOT NULL,
        [NOTE]          NVarChar(Max)         NOT NULL,
        [ID_AUTHOR]     UniqueIdentifier      NOT NULL,
        CONSTRAINT [PK_Document.DocumentStage] PRIMARY KEY CLUSTERED ([ID])
);
GO
