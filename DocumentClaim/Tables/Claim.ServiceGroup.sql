USE [DocumentClaim]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Claim].[ServiceGroup]
(
        [ID]       UniqueIdentifier      NOT NULL,
        [NAME]     NVarChar(512)         NOT NULL,
        [STATUS]   TinyInt               NOT NULL,
        [LAST]     DateTime              NOT NULL,
        CONSTRAINT [PK_Claim.ServiceGroup] PRIMARY KEY CLUSTERED ([ID])
);
GO
