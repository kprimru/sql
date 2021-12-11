USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Purchase].[TenderPriceValidation]
(
        [TPV_ID]          UniqueIdentifier      NOT NULL,
        [TPV_ID_TENDER]   UniqueIdentifier      NOT NULL,
        [TPV_ID_PV]       UniqueIdentifier      NOT NULL,
        CONSTRAINT [PK_Purchase.TenderPriceValidation] PRIMARY KEY CLUSTERED ([TPV_ID]),
        CONSTRAINT [FK_Purchase.TenderPriceValidation(TPV_ID_PV)_Purchase.PriceValidation(PV_ID)] FOREIGN KEY  ([TPV_ID_PV]) REFERENCES [Purchase].[PriceValidation] ([PV_ID]),
        CONSTRAINT [FK_Purchase.TenderPriceValidation(TPV_ID_TENDER)_Purchase.Tender(TD_ID)] FOREIGN KEY  ([TPV_ID_TENDER]) REFERENCES [Purchase].[Tender] ([TD_ID])
);
GO
