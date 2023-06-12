USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Purchase].[TenderTradeSite]
(
        [TTS_ID]          UniqueIdentifier      NOT NULL,
        [TTS_ID_TENDER]   UniqueIdentifier      NOT NULL,
        [TTS_ID_TS]       UniqueIdentifier      NOT NULL,
        CONSTRAINT [PK_Purchase.TenderTradeSite] PRIMARY KEY NONCLUSTERED ([TTS_ID]),
        CONSTRAINT [FK_Purchase.TenderTradeSite(TTS_ID_TS)_Purchase.TradeSite(TS_ID)] FOREIGN KEY  ([TTS_ID_TS]) REFERENCES [Purchase].[TradeSite] ([TS_ID]),
        CONSTRAINT [FK_Purchase.TenderTradeSite(TTS_ID_TENDER)_Purchase.Tender(TD_ID)] FOREIGN KEY  ([TTS_ID_TENDER]) REFERENCES [Purchase].[Tender] ([TD_ID])
);
GO
CREATE CLUSTERED INDEX [IC_Purchase.TenderTradeSite(TTS_ID_TENDER)] ON [Purchase].[TenderTradeSite] ([TTS_ID_TENDER] ASC);
CREATE NONCLUSTERED INDEX [IX_Purchase.TenderTradeSite(TTS_ID_TS)+(TTS_ID_TENDER)] ON [Purchase].[TenderTradeSite] ([TTS_ID_TS] ASC) INCLUDE ([TTS_ID_TENDER]);
GO
