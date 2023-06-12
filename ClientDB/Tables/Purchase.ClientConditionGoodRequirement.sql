USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Purchase].[ClientConditionGoodRequirement]
(
        [CCGR_ID]      UniqueIdentifier      NOT NULL,
        [CCGR_ID_CC]   UniqueIdentifier      NOT NULL,
        [CCGR_ID_GR]   UniqueIdentifier      NOT NULL,
        CONSTRAINT [PK_Purchase.ClientConditionGoodRequirement] PRIMARY KEY CLUSTERED ([CCGR_ID]),
        CONSTRAINT [FK_Purchase.ClientConditionGoodRequirement(CCGR_ID_GR)_Purchase.GoodRequirement(GR_ID)] FOREIGN KEY  ([CCGR_ID_GR]) REFERENCES [Purchase].[GoodRequirement] ([GR_ID]),
        CONSTRAINT [FK_Purchase.ClientConditionGoodRequirement(CCGR_ID_CC)_Purchase.ClientConditionCard(CC_ID)] FOREIGN KEY  ([CCGR_ID_CC]) REFERENCES [Purchase].[ClientConditionCard] ([CC_ID])
);
GO
CREATE NONCLUSTERED INDEX [IX_Purchase.ClientConditionGoodRequirement(CCGR_ID_CC)+(CCGR_ID_GR)] ON [Purchase].[ClientConditionGoodRequirement] ([CCGR_ID_CC] ASC) INCLUDE ([CCGR_ID_GR]);
CREATE NONCLUSTERED INDEX [IX_Purchase.ClientConditionGoodRequirement(CCGR_ID_GR)] ON [Purchase].[ClientConditionGoodRequirement] ([CCGR_ID_GR] ASC);
GO
