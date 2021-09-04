USE [SaleDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Price].[CommercialOfferDetail]
(
        [ID]                    UniqueIdentifier      NOT NULL,
        [ID_OFFER]              UniqueIdentifier      NOT NULL,
        [ID_OPERATION]          UniqueIdentifier      NOT NULL,
        [VARIANT]               SmallInt                  NULL,
        [ID_PERIOD]             UniqueIdentifier          NULL,
        [MON_CNT]               Int                       NULL,
        [ID_SYSTEM]             UniqueIdentifier          NULL,
        [ID_OLD_SYSTEM]         UniqueIdentifier          NULL,
        [OLD_SYSTEM_DISCOUNT]   decimal                   NULL,
        [ID_NEW_SYSTEM]         UniqueIdentifier          NULL,
        [ID_NET]                UniqueIdentifier          NULL,
        [ID_OLD_NET]            UniqueIdentifier          NULL,
        [ID_NEW_NET]            UniqueIdentifier          NULL,
        [ID_ACTION]             UniqueIdentifier          NULL,
        [ID_TAX]                UniqueIdentifier      NOT NULL,
        [DELIVERY_DISCOUNT]     decimal                   NULL,
        [SUPPORT_DISCOUNT]      decimal                   NULL,
        [FURTHER_DISCOUNT]      decimal                   NULL,
        [DELIVERY_INFLATION]    decimal                   NULL,
        [SUPPORT_INFLATION]     decimal                   NULL,
        [FURTHER_INFLATION]     decimal                   NULL,
        [DEL_FREE]              Bit                       NULL,
        [DELIVERY_ORIGIN]       Money                     NULL,
        [DELIVERY_PRICE]        Money                     NULL,
        [SUPPORT_ORIGIN]        Money                     NULL,
        [SUPPORT_PRICE]         Money                     NULL,
        [SUPPORT_FURTHER]       Money                     NULL,
        CONSTRAINT [PK_CommercialOfferDetail] PRIMARY KEY CLUSTERED ([ID]),
        CONSTRAINT [FK_CommercialOfferDetail_CommercialOperation] FOREIGN KEY  ([ID_OPERATION]) REFERENCES [Price].[CommercialOperation] ([ID]),
        CONSTRAINT [FK_CommercialOfferDetail_Tax] FOREIGN KEY  ([ID_TAX]) REFERENCES [Common].[Tax] ([ID]),
        CONSTRAINT [FK_CommercialOfferDetail_Action] FOREIGN KEY  ([ID_ACTION]) REFERENCES [Price].[Action] ([ID]),
        CONSTRAINT [FK_CommercialOfferDetail_CommercialOffer] FOREIGN KEY  ([ID_OFFER]) REFERENCES [Price].[CommercialOffer] ([ID])
);GO
