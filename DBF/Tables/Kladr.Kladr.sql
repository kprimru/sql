USE [DBF]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Kladr].[Kladr]
(
        [KL_ID]       UniqueIdentifier      NOT NULL,
        [KL_NAME]     NVarChar(256)             NULL,
        [KL_SOCR]     NVarChar(128)             NULL,
        [KL_CODE]     NVarChar(64)              NULL,
        [KL_INDEX]    NVarChar(32)              NULL,
        [KL_GNINMB]   NVarChar(32)              NULL,
        [KL_UNO]      NVarChar(32)              NULL,
        [KL_OCATD]    NVarChar(64)              NULL,
        [KL_STATUS]   NVarChar(8)               NULL,
        CONSTRAINT [PK_Kladr.Kladr] PRIMARY KEY NONCLUSTERED ([KL_ID])
);
GO
CREATE CLUSTERED INDEX [IC_Kladr.Kladr(KL_CODE)] ON [Kladr].[Kladr] ([KL_CODE] ASC);
GO
