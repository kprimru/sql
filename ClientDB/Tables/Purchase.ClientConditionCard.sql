USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Purchase].[ClientConditionCard]
(
        [CC_ID]                   UniqueIdentifier      NOT NULL,
        [CC_ID_MASTER]            UniqueIdentifier          NULL,
        [CC_ID_CLIENT]            Int                   NOT NULL,
        [CC_DATE_PUB]             SmallDateTime             NULL,
        [CC_DATE_UPDATE]          SmallDateTime             NULL,
        [CC_DATE_COMPOSE]         SmallDateTime             NULL,
        [CC_DATE_ACTUAL]          SmallDateTime             NULL,
        [CC_ID_LAWYER]            UniqueIdentifier      NOT NULL,
        [CC_APPLY_REASON]         Bit                       NULL,
        [CC_CLAUSE_EXISTS]        Bit                   NOT NULL,
        [CC_CLAUSE_LINK]          VarChar(Max)          NOT NULL,
        [CC_CLAUSE_CLIENT_LINK]   VarChar(Max)          NOT NULL,
        [CC_TRADEMARK]            Bit                       NULL,
        [CC_COMMON_REQ_GOOD]      Bit                       NULL,
        [CC_COMMON_REQ_PARTNER]   Bit                       NULL,
        [CC_VALIDATION_PRICE]     Bit                       NULL,
        [CC_STATUS]               TinyInt               NOT NULL,
        [CC_LAST_UPDATE]          DateTime              NOT NULL,
        [CC_LAST_UPDATE_USER]     NVarChar(256)         NOT NULL,
        CONSTRAINT [PK_Purchase.ClientConditionCard] PRIMARY KEY CLUSTERED ([CC_ID]),
        CONSTRAINT [FK_Purchase.ClientConditionCard(CC_ID_CLIENT)_Purchase.ClientTable(ClientID)] FOREIGN KEY  ([CC_ID_CLIENT]) REFERENCES [dbo].[ClientTable] ([ClientID]),
        CONSTRAINT [FK_Purchase.ClientConditionCard(CC_ID_LAWYER)_Purchase.Lawyer(LW_ID)] FOREIGN KEY  ([CC_ID_LAWYER]) REFERENCES [dbo].[Lawyer] ([LW_ID]),
        CONSTRAINT [FK_Purchase.ClientConditionCard(CC_ID_MASTER)_Purchase.ClientConditionCard(CC_ID)] FOREIGN KEY  ([CC_ID_MASTER]) REFERENCES [Purchase].[ClientConditionCard] ([CC_ID])
);
GO
CREATE NONCLUSTERED INDEX [IX_Purchase.ClientConditionCard(CC_ID_CLIENT,CC_STATUS)] ON [Purchase].[ClientConditionCard] ([CC_ID_CLIENT] ASC, [CC_STATUS] ASC);
GO
