USE [SaleDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Client].[DEPOInfo]
(
        [ID]               UniqueIdentifier      NOT NULL,
        [NAME]             NVarChar(400)         NOT NULL,
        [INN]              NVarChar(40)          NOT NULL,
        [REGION]           NVarChar(60)          NOT NULL,
        [CITY]             NVarChar(100)         NOT NULL,
        [ADDRESS]          NVarChar(400)         NOT NULL,
        [FIO1]             NVarChar(400)         NOT NULL,
        [PHONE1]           NVarChar(24)          NOT NULL,
        [FIO2]             NVarChar(400)             NULL,
        [PHONE2]           NVarChar(24)              NULL,
        [FIO3]             NVarChar(400)             NULL,
        [PHONE3]           NVarChar(24)              NULL,
        [Rival]            Int                       NULL,
        [COMPANY_NUMBER]   Int                       NULL,
        CONSTRAINT [PK_DEPOInfo] PRIMARY KEY CLUSTERED ([ID])
);GO
