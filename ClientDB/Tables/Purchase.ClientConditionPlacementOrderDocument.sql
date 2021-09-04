USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Purchase].[ClientConditionPlacementOrderDocument]
(
        [ID]       UniqueIdentifier      NOT NULL,
        [ID_CPO]   UniqueIdentifier      NOT NULL,
        [ID_DC]    UniqueIdentifier      NOT NULL,
        CONSTRAINT [PK_Purchase.ClientConditionPlacementOrderDocument] PRIMARY KEY CLUSTERED ([ID]),
        CONSTRAINT [FK_Purchase.ClientConditionPlacementOrderDocument(ID_DC)_Purchase.Document(DC_ID)] FOREIGN KEY  ([ID_DC]) REFERENCES [Purchase].[Document] ([DC_ID]),
        CONSTRAINT [FK_Purchase.ClientConditionPlacementOrderDocument(ID_CPO)_Purchase.ClientConditionPlacementOrder] FOREIGN KEY  ([ID_CPO]) REFERENCES [Purchase].[ClientConditionPlacementOrder] ([CPO_ID])
);
GO
CREATE NONCLUSTERED INDEX [IX_Purchase.ClientConditionPlacementOrderDocument(ID_CPO)+(ID_DC)] ON [Purchase].[ClientConditionPlacementOrderDocument] ([ID_CPO] ASC) INCLUDE ([ID_DC]);
CREATE NONCLUSTERED INDEX [IX_Purchase.ClientConditionPlacementOrderDocument(ID_DC)] ON [Purchase].[ClientConditionPlacementOrderDocument] ([ID_DC] ASC);
GO
