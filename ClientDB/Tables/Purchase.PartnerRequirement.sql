USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Purchase].[PartnerRequirement]
(
        [PR_ID]      UniqueIdentifier      NOT NULL,
        [PR_NAME]    VarChar(4000)         NOT NULL,
        [PR_SHORT]   VarChar(200)          NOT NULL,
        CONSTRAINT [PK_Purchase.PartnerRequirement] PRIMARY KEY CLUSTERED ([PR_ID])
);
GO
