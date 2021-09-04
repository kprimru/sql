USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Purchase].[TenderPurchaseKind]
(
        [TPK_ID]          UniqueIdentifier      NOT NULL,
        [TPK_ID_TENDER]   UniqueIdentifier      NOT NULL,
        [TPK_ID_PK]       UniqueIdentifier      NOT NULL,
        CONSTRAINT [PK_Purchase.TenderPurchaseKind] PRIMARY KEY NONCLUSTERED ([TPK_ID]),
        CONSTRAINT [FK_Purchase.TenderPurchaseKind(TPK_ID_TENDER)_Purchase.Tender(TD_ID)] FOREIGN KEY  ([TPK_ID_TENDER]) REFERENCES [Purchase].[Tender] ([TD_ID]),
        CONSTRAINT [FK_Purchase.TenderPurchaseKind(TPK_ID_PK)_Purchase.PurchaseKind(PK_ID)] FOREIGN KEY  ([TPK_ID_PK]) REFERENCES [Purchase].[PurchaseKind] ([PK_ID])
);
GO
CREATE CLUSTERED INDEX [IC_Purchase.TenderPurchaseKind(TPK_ID_TENDER)] ON [Purchase].[TenderPurchaseKind] ([TPK_ID_TENDER] ASC);
CREATE NONCLUSTERED INDEX [IX_Purchase.TenderPurchaseKind(TPK_ID_PK)+(TPK_ID_TENDER)] ON [Purchase].[TenderPurchaseKind] ([TPK_ID_PK] ASC) INCLUDE ([TPK_ID_TENDER]);
GO
