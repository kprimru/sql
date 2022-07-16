USE [DocumentClaim]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Claim].[ClientType]
(
        [ID]       UniqueIdentifier      NOT NULL,
        [NAME]     NVarChar(128)         NOT NULL,
        [PSEDO]    NVarChar(128)         NOT NULL,
        [DEF]      TinyInt               NOT NULL,
        [STATUS]   TinyInt               NOT NULL,
        [LAST]     DateTime              NOT NULL,
        CONSTRAINT [PK_Claim.ClientType] PRIMARY KEY CLUSTERED ([ID])
);GO
