USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Purchase].[TenderInfo]
(
        [TI_ID]               UniqueIdentifier      NOT NULL,
        [TI_ID_TENDER]        UniqueIdentifier      NOT NULL,
        [TI_CLAIM_START]      DateTime                  NULL,
        [TI_CLAIM_END]        DateTime                  NULL,
        [TI_CLAIM_EL_END]     DateTime                  NULL,
        [TI_INSPECT_DATE]     DateTime                  NULL,
        [TI_EL_DATE]          DateTime                  NULL,
        [TI_ID_SIGN_PERIOD]   UniqueIdentifier      NOT NULL,
        CONSTRAINT [PK_Purchase.TenderInfo] PRIMARY KEY NONCLUSTERED ([TI_ID]),
        CONSTRAINT [FK_Purchase.TenderInfo(TI_ID_TENDER)_Purchase.Tender(TD_ID)] FOREIGN KEY  ([TI_ID_TENDER]) REFERENCES [Purchase].[Tender] ([TD_ID]),
        CONSTRAINT [FK_Purchase.TenderInfo(TI_ID_SIGN_PERIOD)_Purchase.SignPeriod(SP_ID)] FOREIGN KEY  ([TI_ID_SIGN_PERIOD]) REFERENCES [Purchase].[SignPeriod] ([SP_ID])
);
GO
CREATE UNIQUE CLUSTERED INDEX [UC_Purchase.TenderInfo(TI_ID_TENDER)] ON [Purchase].[TenderInfo] ([TI_ID_TENDER] ASC);
GO
