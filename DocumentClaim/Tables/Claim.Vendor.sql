USE [DocumentClaim]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Claim].[Vendor]
(
        [ID]       UniqueIdentifier      NOT NULL,
        [NAME]     NVarChar(256)         NOT NULL,
        [STATUS]   TinyInt               NOT NULL,
        [LAST]     DateTime              NOT NULL,
        CONSTRAINT [PK_Claim.Vendor] PRIMARY KEY CLUSTERED ([ID])
);GO
