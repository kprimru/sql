USE [DocumentClaim]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Claim].[Service]
(
        [ID]         UniqueIdentifier      NOT NULL,
        [NAME]       NVarChar(512)         NOT NULL,
        [ID_GROUP]   UniqueIdentifier      NOT NULL,
        [STATUS]     TinyInt               NOT NULL,
        [LAST]       DateTime              NOT NULL,
        CONSTRAINT [PK_Claim.Service] PRIMARY KEY CLUSTERED ([ID])
);
GO
