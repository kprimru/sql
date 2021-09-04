USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Purchase].[PurchaseReason]
(
        [PR_ID]     UniqueIdentifier      NOT NULL,
        [PR_NAME]   VarChar(500)          NOT NULL,
        [PR_NUM]    SmallInt              NOT NULL,
        CONSTRAINT [PK_Purchase.PurchaseReason] PRIMARY KEY CLUSTERED ([PR_ID])
);GO
