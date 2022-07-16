USE [DocumentClaim]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Claim].[DocumentService]
(
        [ID]            UniqueIdentifier      NOT NULL,
        [ID_DOCUMENT]   UniqueIdentifier      NOT NULL,
        [ID_SERVICE]    UniqueIdentifier      NOT NULL,
        [CNT]           SmallInt              NOT NULL,
        CONSTRAINT [PK_Claim.DocumentService] PRIMARY KEY CLUSTERED ([ID])
);GO
