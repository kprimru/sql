USE [SaleDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Client].[CompanyDelivery]
(
        [ID]           UniqueIdentifier      NOT NULL,
        [ID_COMPANY]   UniqueIdentifier      NOT NULL,
        [FIO]          NVarChar(512)         NOT NULL,
        [POS]          NVarChar(512)         NOT NULL,
        [EMAIL]        NVarChar(512)         NOT NULL,
        [DATE]         SmallDateTime             NULL,
        [PLAN_DATE]    SmallDateTime             NULL,
        [OFFER]        NVarChar(512)             NULL,
        [STATE]        SmallInt              NOT NULL,
        [PERSONAL]     NVarChar(256)         NOT NULL,
        CONSTRAINT [PK_Client.CompanyDelivery] PRIMARY KEY CLUSTERED ([ID])
);GO
