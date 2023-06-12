USE [SaleDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Client].[OISInfo]
(
        [ID]               UniqueIdentifier      NOT NULL,
        [ID_COMPANY]       UniqueIdentifier      NOT NULL,
        [COMPLECT]         NVarChar(Max)         NOT NULL,
        [TP]               NVarChar(Max)         NOT NULL,
        [SERVICE]          NVarChar(Max)         NOT NULL,
        [LPR]              NVarChar(Max)         NOT NULL,
        [WORK_PERSONAL]    NVarChar(Max)         NOT NULL,
        [CONS_PERSONAL]    NVarChar(Max)         NOT NULL,
        [RIVAL]            NVarChar(Max)         NOT NULL,
        [RIVAL_PARALLEL]   NVarChar(Max)         NOT NULL,
        [CONDITIONS]       NVarChar(Max)         NOT NULL,
        [ACITVITY]         NVarChar(Max)         NOT NULL,
        [NOTE]             NVarChar(Max)         NOT NULL,
        [SALE_DATE]        SmallDateTime             NULL,
        [SERVICE_DATE]     SmallDateTime             NULL,
        CONSTRAINT [PK_Client.OISInfo] PRIMARY KEY CLUSTERED ([ID])
);
GO
