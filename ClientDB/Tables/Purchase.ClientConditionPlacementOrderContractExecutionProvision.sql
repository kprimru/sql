USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Purchase].[ClientConditionPlacementOrderContractExecutionProvision]
(
        [ID]       UniqueIdentifier      NOT NULL,
        [ID_CPO]   UniqueIdentifier      NOT NULL,
        [ID_CEP]   UniqueIdentifier      NOT NULL,
        CONSTRAINT [PK_Purchase.ClientConditionPlacementOrderContractExecutionProvision] PRIMARY KEY CLUSTERED ([ID]),
        CONSTRAINT [FK_Purchase.ClientConditionPlacementOrderContractExecutionProvision(ID_CEP)_Purchase.ContractExecutionProvision(CEP_ID)] FOREIGN KEY  ([ID_CEP]) REFERENCES [Purchase].[ContractExecutionProvision] ([CEP_ID]),
        CONSTRAINT [FK_Purchase.ClientConditionPlacementOrderContractExecutionProvision(ID_CPO)_Purchase.ClientConditionPlacementOrder(CPO_ID)] FOREIGN KEY  ([ID_CPO]) REFERENCES [Purchase].[ClientConditionPlacementOrder] ([CPO_ID])
);
GO
CREATE NONCLUSTERED INDEX [IX_Purchase.ClientConditionPlacementOrderContractExecutionProvision(ID_CEP)] ON [Purchase].[ClientConditionPlacementOrderContractExecutionProvision] ([ID_CEP] ASC);
CREATE NONCLUSTERED INDEX [IX_Purchase.ClientConditionPlacementOrderContractExecutionProvision(ID_CPO)+(ID_CEP)] ON [Purchase].[ClientConditionPlacementOrderContractExecutionProvision] ([ID_CPO] ASC) INCLUDE ([ID_CEP]);
GO
