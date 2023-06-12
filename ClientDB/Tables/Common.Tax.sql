USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Common].[Tax]
(
        [ID]           UniqueIdentifier      NOT NULL,
        [NAME]         NVarChar(256)         NOT NULL,
        [CAPTION]      NVarChar(256)         NOT NULL,
        [RATE]         decimal               NOT NULL,
        [DEFAULT]      Bit                   NOT NULL,
        [TOTAL_RATE]    AS (((100)+[RATE])/(100)) PERSISTED,
        [TAX_RATE]      AS ([RATE]/(100)) PERSISTED,
        CONSTRAINT [PK_Common.Tax] PRIMARY KEY CLUSTERED ([ID])
);
GO
