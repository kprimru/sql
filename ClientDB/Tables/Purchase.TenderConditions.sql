USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Purchase].[TenderConditions]
(
        [TC_ID]                    UniqueIdentifier      NOT NULL,
        [TC_ID_TENDER]             UniqueIdentifier      NOT NULL,
        [TC_START_PRICE]           Money                 NOT NULL,
        [TC_CLAIM_SIZE]            Bit                   NOT NULL,
        [TC_CLAIM_SIZE_VALUE]      Money                     NULL,
        [TC_CONTRACT_SIZE]         Bit                   NOT NULL,
        [TC_CONTRACT_SIZE_VALUE]   Money                     NULL,
        [TC_DELIVERY_BEGIN]        SmallDateTime             NULL,
        [TC_DELIVERY_BEGIN_NOTE]   VarChar(100)              NULL,
        [TC_DELIVERY_END]          SmallDateTime             NULL,
        [TC_DELIVERY_END_NOTE]     VarChar(100)              NULL,
        [TC_ID_PAY_PERIOD]         UniqueIdentifier      NOT NULL,
        CONSTRAINT [PK_Purchase.TenderConditions] PRIMARY KEY NONCLUSTERED ([TC_ID]),
        CONSTRAINT [FK_Purchase.TenderConditions(TC_ID_TENDER)_Purchase.Tender(TD_ID)] FOREIGN KEY  ([TC_ID_TENDER]) REFERENCES [Purchase].[Tender] ([TD_ID]),
        CONSTRAINT [FK_Purchase.TenderConditions(TC_ID_PAY_PERIOD)_Purchase.PayPeriod(PP_ID)] FOREIGN KEY  ([TC_ID_PAY_PERIOD]) REFERENCES [Purchase].[PayPeriod] ([PP_ID])
);
GO
CREATE UNIQUE CLUSTERED INDEX [UC_Purchase.TenderConditions(TC_ID_TENDER)] ON [Purchase].[TenderConditions] ([TC_ID_TENDER] ASC);
CREATE NONCLUSTERED INDEX [IX_Purchase.TenderConditions(TC_START_PRICE)+(TC_ID_TENDER)] ON [Purchase].[TenderConditions] ([TC_START_PRICE] ASC) INCLUDE ([TC_ID_TENDER]);
GO
