USE [DBF]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Kladr].[Flat]
(
        [KF_ID]       UniqueIdentifier      NOT NULL,
        [KF_NAME]     NVarChar(256)             NULL,
        [KF_CODE]     NVarChar(128)             NULL,
        [KF_INDEX]    NVarChar(32)              NULL,
        [KF_GNINMB]   NVarChar(32)              NULL,
        [KF_UNO]      NVarChar(32)              NULL,
        [KF_NP]       NVarChar(32)              NULL,
        CONSTRAINT [PK_Kladr.Flat] PRIMARY KEY CLUSTERED ([KF_ID])
);GO
