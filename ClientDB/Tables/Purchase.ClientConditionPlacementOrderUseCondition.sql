USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Purchase].[ClientConditionPlacementOrderUseCondition]
(
        [ID]       UniqueIdentifier      NOT NULL,
        [ID_CPO]   UniqueIdentifier      NOT NULL,
        [ID_UC]    UniqueIdentifier      NOT NULL,
        CONSTRAINT [PK_Purchase.ClientConditionPlacementOrderUseCondition] PRIMARY KEY CLUSTERED ([ID]),
        CONSTRAINT [FK_Purchase.ClientConditionPlacementOrderUseCondition(ID_UC)_Purchase.UseCondition(UC_ID)] FOREIGN KEY  ([ID_UC]) REFERENCES [Purchase].[UseCondition] ([UC_ID]),
        CONSTRAINT [FK_Purchase.ClientConditionPlacementOrderUseCondition(ID_CPO)_Purchase.ClientConditionPlacementOrder] FOREIGN KEY  ([ID_CPO]) REFERENCES [Purchase].[ClientConditionPlacementOrder] ([CPO_ID])
);
GO
CREATE NONCLUSTERED INDEX [IX_Purchase.ClientConditionPlacementOrderUseCondition(ID_CPO)+(ID_UC)] ON [Purchase].[ClientConditionPlacementOrderUseCondition] ([ID_CPO] ASC) INCLUDE ([ID_UC]);
CREATE NONCLUSTERED INDEX [IX_Purchase.ClientConditionPlacementOrderUseCondition(ID_UC)] ON [Purchase].[ClientConditionPlacementOrderUseCondition] ([ID_UC] ASC);
GO
