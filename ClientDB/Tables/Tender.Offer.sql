USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Tender].[Offer]
(
        [ID]               UniqueIdentifier      NOT NULL,
        [ID_MASTER]        UniqueIdentifier          NULL,
        [ID_TENDER]        UniqueIdentifier      NOT NULL,
        [DATE]             DateTime              NOT NULL,
        [ID_VENDOR]        UniqueIdentifier      NOT NULL,
        [ID_TAX]           UniqueIdentifier      NOT NULL,
        [ACTUAL]           Bit                   NOT NULL,
        [ACTUAL_START]     SmallDateTime             NULL,
        [ACTUAL_FINISH]    SmallDateTime             NULL,
        [ACTUAL_DATE]      SmallDateTime             NULL,
        [ACTUAL_TYPES]     NVarChar(Max)             NULL,
        [ACTUAL_COEF]      decimal                   NULL,
        [EXCHANGE]         Bit                   NOT NULL,
        [EXCHANGE_TYPES]   NVarChar(Max)             NULL,
        [EXCHANGE_COEF]    decimal                   NULL,
        [DELIVERY]         Bit                   NOT NULL,
        [DELIVERY_TYPES]   NVarChar(Max)             NULL,
        [DELIVERY_COEF]    decimal                   NULL,
        [SUPPORT]          Bit                   NOT NULL,
        [SUPPORT_START]    SmallDateTime             NULL,
        [SUPPORT_FINISH]   SmallDateTime             NULL,
        [SUPPORT_TYPES]    NVarChar(Max)             NULL,
        [SUPPORT_COEF]     decimal                   NULL,
        [QUERY_DATE]       SmallDateTime             NULL,
        [TPL]              NVarChar(256)         NOT NULL,
        [STATUS]           TinyInt               NOT NULL,
        [UPD_DATE]         DateTime              NOT NULL,
        [UPD_USER]         NVarChar(256)         NOT NULL,
        CONSTRAINT [PK_Tender.Offer] PRIMARY KEY CLUSTERED ([ID])
);
GO
