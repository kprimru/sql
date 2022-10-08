USE [DocumentClaim]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Claim].[DocumentDetail]
(
        [ID]               UniqueIdentifier      NOT NULL,
        [ID_DOCUMENT]      UniqueIdentifier      NOT NULL,
        [ID_SYSTEM]        UniqueIdentifier      NOT NULL,
        [ID_NEW_SYSTEM]    UniqueIdentifier          NULL,
        [ID_NET]           UniqueIdentifier      NOT NULL,
        [ID_NEW_NET]       UniqueIdentifier          NULL,
        [ID_ACTION]        UniqueIdentifier          NULL,
        [CNT]              SmallInt              NOT NULL,
        [DISCOUNT]         decimal                   NULL,
        [ID_TYPE]          UniqueIdentifier          NULL,
        [ID_MONTH_BONUS]   UniqueIdentifier          NULL,
        [ID_CONDITIONS]    NVarChar(Max)             NULL,
        [INFLATION]        decimal                   NULL,
        CONSTRAINT [PK_Claim.DocumentDetail] PRIMARY KEY CLUSTERED ([ID]),
        CONSTRAINT [FK_Claim.DocumentDetail(ID_MONTH_BONUS)_Claim.MonthBonus(ID)] FOREIGN KEY  ([ID_MONTH_BONUS]) REFERENCES [Claim].[MonthBonus] ([ID]),
        CONSTRAINT [FK_Claim.DocumentDetail(ID_TYPE)_Claim.Type(ID)] FOREIGN KEY  ([ID_TYPE]) REFERENCES [Distr].[Type] ([ID])
);
GO
CREATE NONCLUSTERED INDEX [IX_Claim.DocumentDetail(ID_DOCUMENT)] ON [Claim].[DocumentDetail] ([ID_DOCUMENT] ASC);
CREATE NONCLUSTERED INDEX [IX_Claim.DocumentDetail(ID_NEW_SYSTEM)+(ID_DOCUMENT)] ON [Claim].[DocumentDetail] ([ID_NEW_SYSTEM] ASC) INCLUDE ([ID_DOCUMENT]);
CREATE NONCLUSTERED INDEX [IX_Claim.DocumentDetail(ID_SYSTEM)+(ID_DOCUMENT)] ON [Claim].[DocumentDetail] ([ID_SYSTEM] ASC) INCLUDE ([ID_DOCUMENT]);
GO
