USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Tender].[Calc]
(
        [ID]             UniqueIdentifier      NOT NULL,
        [ID_MASTER]      UniqueIdentifier          NULL,
        [ID_TENDER]      UniqueIdentifier      NOT NULL,
        [ID_DIRECTION]   UniqueIdentifier      NOT NULL,
        [NAME]           NVarChar(256)         NOT NULL,
        [DATE]           DateTime              NOT NULL,
        [PRICE]          Money                     NULL,
        [CALC_DATA]      NVarChar(Max)             NULL,
        [NOTE]           NVarChar(Max)         NOT NULL,
        [STATUS]         TinyInt               NOT NULL,
        [UPD_DATE]       DateTime              NOT NULL,
        [UPD_USER]       NVarChar(256)         NOT NULL,
        CONSTRAINT [PK_Tender.Calc] PRIMARY KEY CLUSTERED ([ID])
);
GO
