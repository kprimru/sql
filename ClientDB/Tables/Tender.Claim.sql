USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Tender].[Claim]
(
        [ID]                 UniqueIdentifier      NOT NULL,
        [ID_TENDER]          UniqueIdentifier          NULL,
        [TP]                 TinyInt                   NULL,
        [CLAIM_DATE]         DateTime                  NULL,
        [PARAMS]             NVarChar(Max)             NULL,
        [PROVISION_RETURN]   NVarChar(512)             NULL,
        CONSTRAINT [PK_Tender.Claim] PRIMARY KEY CLUSTERED ([ID])
);GO
