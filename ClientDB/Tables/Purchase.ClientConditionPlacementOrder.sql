USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Purchase].[ClientConditionPlacementOrder]
(
        [CPO_ID]                    UniqueIdentifier      NOT NULL,
        [CPO_ID_CC]                 UniqueIdentifier      NOT NULL,
        [CPO_ID_PO]                 UniqueIdentifier      NOT NULL,
        [CPO_USE_CONDITION]         Bit                       NULL,
        [CPO_CLAIM_CANCEL_REASON]   Bit                       NULL,
        [CPO_CLAIM_PROVISION]       Bit                       NULL,
        [CPO_CONTRACT_PROVISION]    Bit                       NULL,
        [CPO_DOCUMENT]              Bit                       NULL,
        [CPO_OTHER_PROVISION]       Bit                       NULL,
        [OLD_ID]                    UniqueIdentifier          NULL,
        CONSTRAINT [PK_Purchase.ClientConditionPlacementOrder] PRIMARY KEY NONCLUSTERED ([CPO_ID]),
        CONSTRAINT [FK_Purchase.ClientConditionPlacementOrder(CPO_ID_PO)_Purchase.PlacementOrder(PO_ID)] FOREIGN KEY  ([CPO_ID_PO]) REFERENCES [Purchase].[PlacementOrder] ([PO_ID]),
        CONSTRAINT [FK_Purchase.ClientConditionPlacementOrder(CPO_ID_CC)_Purchase.ClientConditionCard(CC_ID)] FOREIGN KEY  ([CPO_ID_CC]) REFERENCES [Purchase].[ClientConditionCard] ([CC_ID])
);
GO
CREATE UNIQUE CLUSTERED INDEX [UC_Purchase.ClientConditionPlacementOrder(CPO_ID_CC,CPO_ID_PO)] ON [Purchase].[ClientConditionPlacementOrder] ([CPO_ID_CC] ASC, [CPO_ID_PO] ASC);
GO
