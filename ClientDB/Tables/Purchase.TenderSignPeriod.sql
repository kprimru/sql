USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Purchase].[TenderSignPeriod]
(
        [TSP_ID]          UniqueIdentifier      NOT NULL,
        [TSP_ID_TENDER]   UniqueIdentifier      NOT NULL,
        [TSP_ID_SP]       UniqueIdentifier      NOT NULL,
        CONSTRAINT [PK_Purchase.TenderSignPeriod] PRIMARY KEY CLUSTERED ([TSP_ID]),
        CONSTRAINT [FK_Purchase.TenderSignPeriod(TSP_ID_SP)_Purchase.SignPeriod(SP_ID)] FOREIGN KEY  ([TSP_ID_SP]) REFERENCES [Purchase].[SignPeriod] ([SP_ID]),
        CONSTRAINT [FK_Purchase.TenderSignPeriod(TSP_ID_TENDER)_Purchase.Tender(TD_ID)] FOREIGN KEY  ([TSP_ID_TENDER]) REFERENCES [Purchase].[Tender] ([TD_ID])
);GO
