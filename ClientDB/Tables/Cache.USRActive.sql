USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Cache].[USRActive]
(
        [UD_ID]                  Int              NOT NULL,
        [UF_ID]                  Int              NOT NULL,
        [UD_DISTR]               Int                  NULL,
        [UD_COMP]                TinyInt              NULL,
        [UF_DATE]                DateTime             NULL,
        [USRFileKindShortName]   VarChar(50)      NOT NULL,
        [UF_UPTIME]              VarChar(20)          NULL,
        [UF_ACTIVE]              Bit              NOT NULL,
        [UD_ID_CLIENT]           Int                  NULL,
        [UF_CREATE]              DateTime         NOT NULL,
        [UF_PATH]                TinyInt          NOT NULL,
        [UD_ACTIVE]              Bit              NOT NULL,
        [UF_ID_SYSTEM]           Int                  NULL,
        [UD_ID_HOST]             Int                  NULL,
        CONSTRAINT [PK_Cache.USRActive] PRIMARY KEY CLUSTERED ([UD_ID])
);
GO
CREATE NONCLUSTERED INDEX [IX_Cache.USRActive(UD_ID_CLIENT)+(UF_ID,UD_DISTR,UD_COMP,UF_ID_SYSTEM)] ON [Cache].[USRActive] ([UD_ID_CLIENT] ASC) INCLUDE ([UF_ID], [UD_DISTR], [UD_COMP], [UF_ID_SYSTEM]);
CREATE UNIQUE NONCLUSTERED INDEX [UX_Cache.USRActive(UF_ID)] ON [Cache].[USRActive] ([UF_ID] ASC);
GO
