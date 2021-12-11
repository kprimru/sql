USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Purchase].[PurchaseType]
(
        [PT_ID]     UniqueIdentifier      NOT NULL,
        [PT_NAME]   VarChar(50)           NOT NULL,
        CONSTRAINT [PK_Purchase.PurchaseType] PRIMARY KEY CLUSTERED ([PT_ID])
);
GO
