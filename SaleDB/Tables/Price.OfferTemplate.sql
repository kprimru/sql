USE [SaleDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Price].[OfferTemplate]
(
        [ID]              UniqueIdentifier      NOT NULL,
        [SHORT]           NVarChar(256)         NOT NULL,
        [FILE_NAME]       NVarChar(1024)        NOT NULL,
        [DEMO_FILE]       NVarChar(1024)            NULL,
        [MASTER_PROC]     NVarChar(1024)        NOT NULL,
        [DETAIL_1_PROC]   NVarChar(1024)            NULL,
        [DETAIL_2_PROC]   NVarChar(1024)            NULL,
        [LAST]            DateTime              NOT NULL,
        CONSTRAINT [PK_Price.OfferTemplate] PRIMARY KEY CLUSTERED ([ID])
);GO
