USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Purchase].[ClientConditionPlacementOrderOtherProvision]
(
        [ID]       UniqueIdentifier      NOT NULL,
        [ID_CPO]   UniqueIdentifier      NOT NULL,
        [ID_OP]    UniqueIdentifier      NOT NULL,
        CONSTRAINT [PK_Purchase.ClientConditionPlacementOrderOtherProvision] PRIMARY KEY CLUSTERED ([ID]),
        CONSTRAINT [Purchase.ClientConditionPlacementOrder3] FOREIGN KEY  ([ID_CPO]) REFERENCES [Purchase].[ClientConditionPlacementOrder] ([CPO_ID]),
        CONSTRAINT [FK_Purchase.ClientConditionPlacementOrderOtherProvision(ID_OP)_Purchase.OtherProvision(OP_ID)] FOREIGN KEY  ([ID_OP]) REFERENCES [Purchase].[OtherProvision] ([OP_ID])
);
GO
CREATE NONCLUSTERED INDEX [IX_Purchase.ClientConditionPlacementOrderOtherProvision(ID_CPO)+(ID_OP)] ON [Purchase].[ClientConditionPlacementOrderOtherProvision] ([ID_CPO] ASC) INCLUDE ([ID_OP]);
CREATE NONCLUSTERED INDEX [IX_Purchase.ClientConditionPlacementOrderOtherProvision(ID_OP)] ON [Purchase].[ClientConditionPlacementOrderOtherProvision] ([ID_OP] ASC);
GO
