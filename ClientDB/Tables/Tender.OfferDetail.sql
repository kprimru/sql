USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Tender].[OfferDetail]
(
        [ID]              UniqueIdentifier      NOT NULL,
        [ID_OFFER]        UniqueIdentifier      NOT NULL,
        [ID_CLIENT]       Int                       NULL,
        [CLIENT]          NVarChar(512)         NOT NULL,
        [ADDRESS]         NVarChar(4096)        NOT NULL,
        [ID_SYSTEM]       Int                   NOT NULL,
        [ID_OLD_SYSTEM]   Int                       NULL,
        [DISTR]           NVarChar(128)         NOT NULL,
        [ID_NET]          Int                   NOT NULL,
        [ID_OLD_NET]      Int                       NULL,
        [DELIVERY_BASE]   Money                     NULL,
        [DELIVERY]        Money                     NULL,
        [EXCHANGE_BASE]   Money                     NULL,
        [EXCHANGE]        Money                     NULL,
        [ACTUAL_BASE]     Money                     NULL,
        [ACTUAL]          Money                     NULL,
        [SUPPORT_BASE]    Money                     NULL,
        [SUPPORT]         Money                     NULL,
        [SUPPORT_TOTAL]   Money                     NULL,
        [MON_CNT]         SmallInt                  NULL,
        CONSTRAINT [PK_Tender.OfferDetail] PRIMARY KEY CLUSTERED ([ID])
);
GO
CREATE NONCLUSTERED INDEX [IX_Tender.OfferDetail(ID_OFFER)+(CLIENT)] ON [Tender].[OfferDetail] ([ID_OFFER] ASC) INCLUDE ([CLIENT]);
GO
