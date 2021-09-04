USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Purchase].[ClientConditionPlacementOrderClaimProvision]
(
        [ID]       UniqueIdentifier      NOT NULL,
        [ID_CPO]   UniqueIdentifier      NOT NULL,
        [ID_CP]    UniqueIdentifier      NOT NULL,
        CONSTRAINT [PK_Purchase.ClientConditionPlacementOrderClaimProvision] PRIMARY KEY CLUSTERED ([ID]),
        CONSTRAINT [FK_Purchase.ClientConditionPlacementOrderClaimProvision(ID_CP)_Purchase.ClaimProvision(CP_ID)] FOREIGN KEY  ([ID_CP]) REFERENCES [Purchase].[ClaimProvision] ([CP_ID]),
        CONSTRAINT [Purchase.ClientConditionPlacementOrder1] FOREIGN KEY  ([ID_CPO]) REFERENCES [Purchase].[ClientConditionPlacementOrder] ([CPO_ID])
);
GO
CREATE NONCLUSTERED INDEX [IX_Purchase.ClientConditionPlacementOrderClaimProvision(ID_CP)] ON [Purchase].[ClientConditionPlacementOrderClaimProvision] ([ID_CP] ASC);
CREATE NONCLUSTERED INDEX [IX_Purchase.ClientConditionPlacementOrderClaimProvision(ID_CPO)+(ID_CP)] ON [Purchase].[ClientConditionPlacementOrderClaimProvision] ([ID_CPO] ASC) INCLUDE ([ID_CP]);
GO
