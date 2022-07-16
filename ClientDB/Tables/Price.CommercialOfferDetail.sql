USE [ClientDB]
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
        [ID_SYSTEM]             Int                       NULL,
        [ID_OLD_SYSTEM]         Int                       NULL,
        [OLD_SYSTEM_DISCOUNT]   decimal                   NULL,
        [ID_NEW_SYSTEM]         Int                       NULL,
        [ID_NET]                Int                       NULL,
        [ID_OLD_NET]            Int                       NULL,
        [ID_NEW_NET]            Int                       NULL,
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
        [FURTHER_RND]           Bit                       NULL,
        [CONNECT_PRICE]         Money                     NULL,
        CONSTRAINT [PK_Price.CommercialOfferDetail] PRIMARY KEY NONCLUSTERED ([ID]),
        CONSTRAINT [FK_Price.CommercialOfferDetail(ID_NEW_SYSTEM)_Price.SystemTable(SystemID)] FOREIGN KEY  ([ID_NEW_SYSTEM]) REFERENCES [dbo].[SystemTable] ([SystemID]),
        CONSTRAINT [FK_Price.CommercialOfferDetail(ID_OLD_SYSTEM)_Price.SystemTable(SystemID)] FOREIGN KEY  ([ID_OLD_SYSTEM]) REFERENCES [dbo].[SystemTable] ([SystemID]),
        CONSTRAINT [FK_Price.CommercialOfferDetail(ID_SYSTEM)_Price.SystemTable(SystemID)] FOREIGN KEY  ([ID_SYSTEM]) REFERENCES [dbo].[SystemTable] ([SystemID]),
        CONSTRAINT [FK_Price.CommercialOfferDetail(ID_OPERATION)_Price.CommercialOperation(ID)] FOREIGN KEY  ([ID_OPERATION]) REFERENCES [Price].[CommercialOperation] ([ID]),
        CONSTRAINT [FK_Price.CommercialOfferDetail(ID_ACTION)_Price.Action(ID)] FOREIGN KEY  ([ID_ACTION]) REFERENCES [Price].[Action] ([ID]),
        CONSTRAINT [FK_Price.CommercialOfferDetail(ID_NET)_Price.DistrTypeTable(DistrTypeID)] FOREIGN KEY  ([ID_NET]) REFERENCES [dbo].[DistrTypeTable] ([DistrTypeID]),
        CONSTRAINT [FK_Price.CommercialOfferDetail(ID_NEW_NET)_Price.DistrTypeTable(DistrTypeID)] FOREIGN KEY  ([ID_NEW_NET]) REFERENCES [dbo].[DistrTypeTable] ([DistrTypeID]),
        CONSTRAINT [FK_Price.CommercialOfferDetail(ID_OLD_NET)_Price.DistrTypeTable(DistrTypeID)] FOREIGN KEY  ([ID_OLD_NET]) REFERENCES [dbo].[DistrTypeTable] ([DistrTypeID]),
        CONSTRAINT [FK_Price.CommercialOfferDetail(ID_TAX)_Price.Tax(ID)] FOREIGN KEY  ([ID_TAX]) REFERENCES [Common].[Tax] ([ID]),
        CONSTRAINT [FK_Price.CommercialOfferDetail(ID_PERIOD)_Price.Period(ID)] FOREIGN KEY  ([ID_PERIOD]) REFERENCES [Common].[Period] ([ID]),
        CONSTRAINT [FK_Price.CommercialOfferDetail(ID_OFFER)_Price.CommercialOffer(ID)] FOREIGN KEY  ([ID_OFFER]) REFERENCES [Price].[CommercialOffer] ([ID])
);
GO
CREATE UNIQUE CLUSTERED INDEX [UC_Price.CommercialOfferDetail(ID_OFFER,ID)] ON [Price].[CommercialOfferDetail] ([ID_OFFER] ASC, [ID] ASC);
GO
