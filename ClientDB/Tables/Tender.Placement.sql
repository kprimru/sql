USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Tender].[Placement]
(
        [ID]                 UniqueIdentifier      NOT NULL,
        [ID_TENDER]          UniqueIdentifier      NOT NULL,
        [SUBJECT]            NVarChar(512)             NULL,
        [ID_TYPE]            UniqueIdentifier          NULL,
        [NOTICE_NUM]         NVarChar(256)             NULL,
        [DATE]               SmallDateTime             NULL,
        [GK_SUM]             Money                     NULL,
        [ID_TRADESITE]       UniqueIdentifier          NULL,
        [URL]                NVarChar(512)             NULL,
        [GK_START]           SmallDateTime             NULL,
        [GK_FINISH]          SmallDateTime             NULL,
        [GK_MONTH]           SmallInt                  NULL,
        [ACTUAL_START]       SmallDateTime             NULL,
        [ACTUAL_FINISH]      SmallDateTime             NULL,
        [ACTUAL_MONTH]       SmallInt                  NULL,
        [CLAIM_START]        SmallDateTime             NULL,
        [CLAIM_FINISH]       SmallDateTime             NULL,
        [OPENING]            SmallDateTime             NULL,
        [REVIEW]             SmallDateTime             NULL,
        [AUCTION]            SmallDateTime             NULL,
        [CLAIM_PRIVISION]    Money                     NULL,
        [GK_PROVISION_PRC]   SmallInt                  NULL,
        [GK_PROVISION_SUM]   Money                     NULL,
        [GK_PROVISION_TAX]   UniqueIdentifier          NULL,
        [EDO_SUM]            Money                     NULL,
        [EDO_TAX]            UniqueIdentifier          NULL,
        [ID_VENDOR]          UniqueIdentifier          NULL,
        [PROTOCOL]           SmallDateTime             NULL,
        [AGREE]              SmallDateTime             NULL,
        [GK_DIRECTION]       SmallDateTime             NULL,
        [GK_SIGN]            SmallDateTime             NULL,
        [GK_SIGN_FACT]       SmallDateTime             NULL,
        [GK_NUM]             NVarChar(256)             NULL,
        [GK_DATE]            SmallDateTime             NULL,
        [GK_DOP_NUM]         NVarChar(256)             NULL,
        [GK_DOP_DATE]        SmallDateTime             NULL,
        [PROVISION_RETURN]   SmallDateTime             NULL,
        [TOTAL]              SmallDateTime             NULL,
        [PART_SUM]           Money                     NULL,
        [TARIFF_SUM]         Money                     NULL,
        [ECP_SUM]            Money                     NULL,
        [INVOICE_NUM]        NVarChar(100)             NULL,
        [INVOICE_DATE]       DateTime                  NULL,
        [COLOR_IGN]          Bit                       NULL,
        CONSTRAINT [PK_Tender.Placement] PRIMARY KEY CLUSTERED ([ID])
);
GO
