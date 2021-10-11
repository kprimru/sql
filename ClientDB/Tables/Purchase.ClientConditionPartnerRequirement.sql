USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Purchase].[ClientConditionPartnerRequirement]
(
        [CCPR_ID]      UniqueIdentifier      NOT NULL,
        [CCPR_ID_CC]   UniqueIdentifier      NOT NULL,
        [CCPR_ID_PR]   UniqueIdentifier      NOT NULL,
        CONSTRAINT [PK_Purchase.ClientConditionPartnerRequirement] PRIMARY KEY CLUSTERED ([CCPR_ID]),
        CONSTRAINT [FK_Purchase.ClientConditionPartnerRequirement(CCPR_ID_PR)_Purchase.PartnerRequirement(PR_ID)] FOREIGN KEY  ([CCPR_ID_PR]) REFERENCES [Purchase].[PartnerRequirement] ([PR_ID]),
        CONSTRAINT [FK_Purchase.ClientConditionPartnerRequirement(CCPR_ID_CC)_Purchase.ClientConditionCard(CC_ID)] FOREIGN KEY  ([CCPR_ID_CC]) REFERENCES [Purchase].[ClientConditionCard] ([CC_ID])
);
GO
CREATE NONCLUSTERED INDEX [IX_Purchase.ClientConditionPartnerRequirement(CCPR_ID_CC)+(CCPR_ID_PR)] ON [Purchase].[ClientConditionPartnerRequirement] ([CCPR_ID_CC] ASC) INCLUDE ([CCPR_ID_PR]);
CREATE NONCLUSTERED INDEX [IX_Purchase.ClientConditionPartnerRequirement(CCPR_ID_PR)] ON [Purchase].[ClientConditionPartnerRequirement] ([CCPR_ID_PR] ASC);
GO
