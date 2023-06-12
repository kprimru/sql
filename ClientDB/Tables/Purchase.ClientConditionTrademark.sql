USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Purchase].[ClientConditionTrademark]
(
        [CCT_ID]      UniqueIdentifier      NOT NULL,
        [CCT_ID_CC]   UniqueIdentifier      NOT NULL,
        [CCT_ID_TM]   UniqueIdentifier      NOT NULL,
        CONSTRAINT [PK_Purchase.ClientConditionTrademark] PRIMARY KEY CLUSTERED ([CCT_ID]),
        CONSTRAINT [FK_Purchase.ClientConditionTrademark(CCT_ID_TM)_Purchase.Trademark(TM_ID)] FOREIGN KEY  ([CCT_ID_TM]) REFERENCES [Purchase].[Trademark] ([TM_ID]),
        CONSTRAINT [FK_Purchase.ClientConditionTrademark(CCT_ID_CC)_Purchase.ClientConditionCard(CC_ID)] FOREIGN KEY  ([CCT_ID_CC]) REFERENCES [Purchase].[ClientConditionCard] ([CC_ID])
);
GO
CREATE NONCLUSTERED INDEX [IX_Purchase.ClientConditionTrademark(CCT_ID_CC)+(CCT_ID_TM)] ON [Purchase].[ClientConditionTrademark] ([CCT_ID_CC] ASC) INCLUDE ([CCT_ID_TM]);
CREATE NONCLUSTERED INDEX [IX_Purchase.ClientConditionTrademark(CCT_ID_TM)] ON [Purchase].[ClientConditionTrademark] ([CCT_ID_TM] ASC);
GO
