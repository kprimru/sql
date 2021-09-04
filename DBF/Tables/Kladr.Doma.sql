USE [DBF]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Kladr].[Doma]
(
        [KD_ID]       UniqueIdentifier      NOT NULL,
        [KD_NAME]     NVarChar(256)             NULL,
        [KD_KORP]     NVarChar(64)              NULL,
        [KD_SOCR]     NVarChar(64)              NULL,
        [KD_CODE]     NVarChar(128)             NULL,
        [KD_INDEX]    NVarChar(32)              NULL,
        [KD_GNINMB]   NVarChar(32)              NULL,
        [KD_UNO]      NVarChar(32)              NULL,
        [KD_OCATD]    NVarChar(64)              NULL,
        CONSTRAINT [PK_Kladr.Doma] PRIMARY KEY CLUSTERED ([KD_ID])
);GO
