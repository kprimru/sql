USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Purchase].[ClientConditionPlacementOrderClaimCancelReason]
(
        [ID]       UniqueIdentifier      NOT NULL,
        [ID_CPO]   UniqueIdentifier      NOT NULL,
        [ID_CCR]   UniqueIdentifier      NOT NULL,
        CONSTRAINT [PK_Purchase.ClientConditionPlacementOrderClaimCancelReason] PRIMARY KEY CLUSTERED ([ID]),
        CONSTRAINT [FK_Purchase.ClientConditionPlacementOrderClaimCancelReason(ID_CCR)_Purchase.ClaimCancelReason] FOREIGN KEY  ([ID_CCR]) REFERENCES [Purchase].[ClaimCancelReason] ([CCR_ID]),
        CONSTRAINT [Purchase.ClientConditionPlacementOrder] FOREIGN KEY  ([ID_CPO]) REFERENCES [Purchase].[ClientConditionPlacementOrder] ([CPO_ID])
);
GO
CREATE NONCLUSTERED INDEX [IX_Purchase.ClientConditionPlacementOrderClaimCancelReason(ID_CCR)] ON [Purchase].[ClientConditionPlacementOrderClaimCancelReason] ([ID_CCR] ASC);
CREATE NONCLUSTERED INDEX [IX_Purchase.ClientConditionPlacementOrderClaimCancelReason(ID_CPO)+(ID_CCR)] ON [Purchase].[ClientConditionPlacementOrderClaimCancelReason] ([ID_CPO] ASC) INCLUDE ([ID_CCR]);
GO
