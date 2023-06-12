USE [DocumentClaim]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Claim].[DocumentDistr]
(
        [ID]            UniqueIdentifier      NOT NULL,
        [ID_DOCUMENT]   UniqueIdentifier      NOT NULL,
        [ID_SYSTEM]     UniqueIdentifier      NOT NULL,
        [ID_NET]        UniqueIdentifier      NOT NULL,
        [DISTR]         Int                       NULL,
        [COMP]          TinyInt                   NULL,
        CONSTRAINT [PK_Claim.DocumentDistr] PRIMARY KEY CLUSTERED ([ID])
);
GO
