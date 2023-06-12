USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Purchase].[ClientConditionTradeSite]
(
        [CTS_ID]      UniqueIdentifier      NOT NULL,
        [CTS_ID_CC]   UniqueIdentifier      NOT NULL,
        [CTS_ID_TS]   UniqueIdentifier      NOT NULL,
        CONSTRAINT [PK_Purchase.ClientConditionTradeSite] PRIMARY KEY CLUSTERED ([CTS_ID]),
        CONSTRAINT [FK_Purchase.ClientConditionTradeSite(CTS_ID_TS)_Purchase.TradeSite(TS_ID)] FOREIGN KEY  ([CTS_ID_TS]) REFERENCES [Purchase].[TradeSite] ([TS_ID]),
        CONSTRAINT [FK_Purchase.ClientConditionTradeSite(CTS_ID_CC)_Purchase.ClientConditionCard(CC_ID)] FOREIGN KEY  ([CTS_ID_CC]) REFERENCES [Purchase].[ClientConditionCard] ([CC_ID])
);
GO
CREATE NONCLUSTERED INDEX [IX_Purchase.ClientConditionTradeSite(CTS_ID_CC)+(CTS_ID_TS)] ON [Purchase].[ClientConditionTradeSite] ([CTS_ID_CC] ASC) INCLUDE ([CTS_ID_TS]);
CREATE NONCLUSTERED INDEX [IX_Purchase.ClientConditionTradeSite(CTS_ID_TS)] ON [Purchase].[ClientConditionTradeSite] ([CTS_ID_TS] ASC);
GO
