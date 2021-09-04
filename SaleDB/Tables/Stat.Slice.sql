USE [SaleDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Stat].[Slice]
(
        [ID]         UniqueIdentifier      NOT NULL,
        [DATE]       SmallDateTime         NOT NULL,
        [TP]         TinyInt               NOT NULL,
        [CNT]        Int                   NOT NULL,
        [STATUS]     TinyInt               NOT NULL,
        [BDATE]      DateTime              NOT NULL,
        [EDATE]      DateTime                  NULL,
        [UPD_USER]   NVarChar(256)         NOT NULL,
        CONSTRAINT [PK_Slice] PRIMARY KEY CLUSTERED ([ID])
);GO
