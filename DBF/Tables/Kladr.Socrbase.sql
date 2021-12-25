USE [DBF]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Kladr].[Socrbase]
(
        [KSB_ID]         UniqueIdentifier      NOT NULL,
        [KSB_LEVEL]      NVarChar(32)              NULL,
        [KSB_SCNAME]     NVarChar(128)             NULL,
        [KSB_SOCRNAME]   NVarChar(256)             NULL,
        [KSB_KOD]        NVarChar(16)              NULL,
        CONSTRAINT [PK_Kladr.Socrbase] PRIMARY KEY CLUSTERED ([KSB_ID])
);GO
