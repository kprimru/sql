USE [DBF_NAH]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Kladr].[KladrTree]
(
        [KT_ID]          UniqueIdentifier      NOT NULL,
        [KT_ID_MASTER]   UniqueIdentifier          NULL,
        [KT_LEVEL]       TinyInt               NOT NULL,
        [KT_NAME]        NVarChar(256)         NOT NULL,
        [KT_PREFIX]      NVarChar(64)              NULL,
        [KT_CODE]        NVarChar(128)             NULL,
        [KT_ACTUAL]      nchar(8)                  NULL,
        CONSTRAINT [PK_Kladr.KladrTree] PRIMARY KEY CLUSTERED ([KT_ID])
);
GO
CREATE NONCLUSTERED INDEX [IX_Kladr.KladrTree(KT_ID_MASTER)+(KT_ID,KT_LEVEL,KT_NAME,KT_PREFIX,KT_CODE,KT_ACTUAL)] ON [Kladr].[KladrTree] ([KT_ID_MASTER] ASC) INCLUDE ([KT_ID], [KT_LEVEL], [KT_NAME], [KT_PREFIX], [KT_CODE], [KT_ACTUAL]);
CREATE NONCLUSTERED INDEX [IX_Kladr.KladrTree(KT_LEVEL,KT_CODE)] ON [Kladr].[KladrTree] ([KT_LEVEL] ASC, [KT_CODE] ASC);
CREATE NONCLUSTERED INDEX [IX_Kladr.KladrTree(KT_LEVEL,KT_NAME)+(KT_ID,KT_ID_MASTER,KT_PREFIX,KT_CODE,KT_ACTUAL)] ON [Kladr].[KladrTree] ([KT_LEVEL] ASC, [KT_NAME] ASC) INCLUDE ([KT_ID], [KT_ID_MASTER], [KT_PREFIX], [KT_CODE], [KT_ACTUAL]);
GO
