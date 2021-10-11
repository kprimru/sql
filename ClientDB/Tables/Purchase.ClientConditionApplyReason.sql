USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Purchase].[ClientConditionApplyReason]
(
        [CAR_ID]      UniqueIdentifier      NOT NULL,
        [CAR_ID_CC]   UniqueIdentifier      NOT NULL,
        [CAR_ID_AR]   UniqueIdentifier      NOT NULL,
        CONSTRAINT [PK_Purchase.ClientConditionApplyReason] PRIMARY KEY CLUSTERED ([CAR_ID]),
        CONSTRAINT [FK_Purchase.ClientConditionApplyReason(CAR_ID_AR)_Purchase.ApplyReason(AR_ID)] FOREIGN KEY  ([CAR_ID_AR]) REFERENCES [Purchase].[ApplyReason] ([AR_ID]),
        CONSTRAINT [FK_Purchase.ClientConditionApplyReason(CAR_ID_CC)_Purchase.ClientConditionCard(CC_ID)] FOREIGN KEY  ([CAR_ID_CC]) REFERENCES [Purchase].[ClientConditionCard] ([CC_ID])
);
GO
CREATE NONCLUSTERED INDEX [IX_Purchase.ClientConditionApplyReason(CAR_ID_AR)] ON [Purchase].[ClientConditionApplyReason] ([CAR_ID_AR] ASC);
CREATE NONCLUSTERED INDEX [IX_Purchase.ClientConditionApplyReason(CAR_ID_CC)+(CAR_ID_AR)] ON [Purchase].[ClientConditionApplyReason] ([CAR_ID_CC] ASC) INCLUDE ([CAR_ID_AR]);
GO
