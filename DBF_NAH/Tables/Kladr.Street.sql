USE [DBF_NAH]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Kladr].[Street]
(
        [KS_ID]       UniqueIdentifier      NOT NULL,
        [KS_NAME]     NVarChar(256)             NULL,
        [KS_SOCR]     NVarChar(128)             NULL,
        [KS_CODE]     NVarChar(128)             NULL,
        [KS_INDEX]    NVarChar(64)              NULL,
        [KS_GNINMB]   NVarChar(32)              NULL,
        [KS_UNO]      NVarChar(32)              NULL,
        [KS_OCATD]    NVarChar(64)              NULL,
        CONSTRAINT [PK_Kladr.Street] PRIMARY KEY CLUSTERED ([KS_ID])
);
GO
CREATE NONCLUSTERED INDEX [IX_Kladr.Street(KS_CODE)] ON [Kladr].[Street] ([KS_CODE] ASC);
GO
