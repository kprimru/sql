USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Purchase].[ClientConditionPriceValidation]
(
        [CCPV_ID]      UniqueIdentifier      NOT NULL,
        [CCPV_ID_CC]   UniqueIdentifier      NOT NULL,
        [CCPV_ID_PV]   UniqueIdentifier      NOT NULL,
        CONSTRAINT [PK_Purchase.ClientConditionPriceValidation] PRIMARY KEY CLUSTERED ([CCPV_ID]),
        CONSTRAINT [FK_Purchase.ClientConditionPriceValidation(CCPV_ID_PV)_Purchase.PriceValidation(PV_ID)] FOREIGN KEY  ([CCPV_ID_PV]) REFERENCES [Purchase].[PriceValidation] ([PV_ID]),
        CONSTRAINT [FK_Purchase.ClientConditionPriceValidation(CCPV_ID_CC)_Purchase.ClientConditionCard(CC_ID)] FOREIGN KEY  ([CCPV_ID_CC]) REFERENCES [Purchase].[ClientConditionCard] ([CC_ID])
);
GO
CREATE NONCLUSTERED INDEX [IX_Purchase.ClientConditionPriceValidation(CCPV_ID_CC)+(CCPV_ID_PV)] ON [Purchase].[ClientConditionPriceValidation] ([CCPV_ID_CC] ASC) INCLUDE ([CCPV_ID_PV]);
GO
