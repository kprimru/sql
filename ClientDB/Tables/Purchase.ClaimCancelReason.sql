USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Purchase].[ClaimCancelReason]
(
        [CCR_ID]      UniqueIdentifier      NOT NULL,
        [CCR_NAME]    VarChar(4000)         NOT NULL,
        [CCR_SHORT]   VarChar(200)          NOT NULL,
        CONSTRAINT [PK_Purchase.ClaimCancelReason] PRIMARY KEY CLUSTERED ([CCR_ID])
);
GO
