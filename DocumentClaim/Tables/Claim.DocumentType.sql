USE [DocumentClaim]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Claim].[DocumentType]
(
        [ID]            UniqueIdentifier      NOT NULL,
        [ID_DOCUMENT]   UniqueIdentifier      NOT NULL,
        [ID_TYPE]       UniqueIdentifier      NOT NULL,
        CONSTRAINT [PK_Claim.DocumentType] PRIMARY KEY CLUSTERED ([ID])
);
GO
CREATE NONCLUSTERED INDEX [IX_Claim.DocumentType(ID_DOCUMENT,ID_TYPE)+(ID)] ON [Claim].[DocumentType] ([ID_DOCUMENT] ASC, [ID_TYPE] ASC) INCLUDE ([ID]);
GO
