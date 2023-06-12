USE [DocumentClaim]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Claim].[MonthBonus]
(
        [ID]       UniqueIdentifier      NOT NULL,
        [SHORT]    NVarChar(256)         NOT NULL,
        [STATUS]   TinyInt               NOT NULL,
        [LAST]     DateTime              NOT NULL,
        CONSTRAINT [PK_Claim.MonthBonus] PRIMARY KEY CLUSTERED ([ID])
);
GO
