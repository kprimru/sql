USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Purchase].[ApplyReason]
(
        [AR_ID]      UniqueIdentifier      NOT NULL,
        [AR_NAME]    VarChar(4000)         NOT NULL,
        [AR_SHORT]   VarChar(200)          NOT NULL,
        CONSTRAINT [PK_Purchase.ApplyReason] PRIMARY KEY CLUSTERED ([AR_ID])
);GO
