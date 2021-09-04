USE [SaleDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Stat].[SliceDetail]
(
        [ID]          UniqueIdentifier      NOT NULL,
        [ID_SLICE]    UniqueIdentifier      NOT NULL,
        [GRP]         NVarChar(512)         NOT NULL,
        [DTL_NAME]    NVarChar(512)         NOT NULL,
        [DTL_COUNT]   Int                   NOT NULL,
        CONSTRAINT [PK_SliceDetail] PRIMARY KEY CLUSTERED ([ID])
);GO
