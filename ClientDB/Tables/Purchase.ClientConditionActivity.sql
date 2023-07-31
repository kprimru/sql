USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Purchase].[ClientConditionActivity]
(
        [CCA_ID]      UniqueIdentifier      NOT NULL,
        [CCA_ID_CC]   UniqueIdentifier      NOT NULL,
        [CCA_ID_AC]   UniqueIdentifier      NOT NULL,
        CONSTRAINT [PK_Purchase.ClientConditionActivity] PRIMARY KEY CLUSTERED ([CCA_ID]),
        CONSTRAINT [FK_Purchase.ClientConditionActivity(CCA_ID_AC)_dbo.Activity(AC_ID)] FOREIGN KEY  ([CCA_ID_AC]) REFERENCES [dbo].[Activity] ([AC_ID]),
        CONSTRAINT [FK_Purchase.ClientConditionActivity(CCA_ID_CC)_Purchase.ClientConditionCard(CC_ID)] FOREIGN KEY  ([CCA_ID_CC]) REFERENCES [Purchase].[ClientConditionCard] ([CC_ID])
);
GO
CREATE NONCLUSTERED INDEX [IX_Purchase.ClientConditionActivity(CCA_ID_AC)] ON [Purchase].[ClientConditionActivity] ([CCA_ID_AC] ASC);
CREATE NONCLUSTERED INDEX [IX_Purchase.ClientConditionActivity(CCA_ID_CC)+(CCA_ID_AC)] ON [Purchase].[ClientConditionActivity] ([CCA_ID_CC] ASC) INCLUDE ([CCA_ID_AC]);
GO
