USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Purchase].[ClientConditionReason]
(
        [CCR_ID]      UniqueIdentifier      NOT NULL,
        [CCR_ID_CC]   UniqueIdentifier      NOT NULL,
        [CCR_ID_PR]   UniqueIdentifier      NOT NULL,
        CONSTRAINT [PK_Purchase.ClientConditionReason] PRIMARY KEY CLUSTERED ([CCR_ID]),
        CONSTRAINT [FK_Purchase.ClientConditionReason(CCR_ID_PR)_Purchase.PurchaseReason(PR_ID)] FOREIGN KEY  ([CCR_ID_PR]) REFERENCES [Purchase].[PurchaseReason] ([PR_ID]),
        CONSTRAINT [FK_Purchase.ClientConditionReason(CCR_ID_CC)_Purchase.ClientConditionCard(CC_ID)] FOREIGN KEY  ([CCR_ID_CC]) REFERENCES [Purchase].[ClientConditionCard] ([CC_ID])
);
GO
CREATE NONCLUSTERED INDEX [IX_Purchase.ClientConditionReason(CCR_ID_CC)+(CCR_ID_PR)] ON [Purchase].[ClientConditionReason] ([CCR_ID_CC] ASC) INCLUDE ([CCR_ID_PR]);
CREATE NONCLUSTERED INDEX [IX_Purchase.ClientConditionReason(CCR_ID_PR)] ON [Purchase].[ClientConditionReason] ([CCR_ID_PR] ASC);
GO
