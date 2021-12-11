USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Purchase].[TenderDocument]
(
        [TDC_ID]          UniqueIdentifier      NOT NULL,
        [TDC_ID_TENDER]   UniqueIdentifier      NOT NULL,
        [TDC_ID_DC]       UniqueIdentifier      NOT NULL,
        CONSTRAINT [PK_Purchase.TenderDocument] PRIMARY KEY CLUSTERED ([TDC_ID]),
        CONSTRAINT [FK_Purchase.TenderDocument(TDC_ID_DC)_Purchase.Document(DC_ID)] FOREIGN KEY  ([TDC_ID_DC]) REFERENCES [Purchase].[Document] ([DC_ID]),
        CONSTRAINT [FK_Purchase.TenderDocument(TDC_ID_TENDER)_Purchase.Tender(TD_ID)] FOREIGN KEY  ([TDC_ID_TENDER]) REFERENCES [Purchase].[Tender] ([TD_ID])
);
GO
