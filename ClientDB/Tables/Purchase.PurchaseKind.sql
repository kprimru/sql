USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Purchase].[PurchaseKind]
(
        [PK_ID]     UniqueIdentifier      NOT NULL,
        [PK_NAME]   VarChar(50)           NOT NULL,
        CONSTRAINT [PK_Purchase.PurchaseKind] PRIMARY KEY CLUSTERED ([PK_ID])
);GO
