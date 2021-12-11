USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [IP].[ClientStatDetailCache]
(
        [CSD_SYS]                SmallInt           NOT NULL,
        [CSD_DISTR]              Int                NOT NULL,
        [CSD_COMP]               SmallInt           NOT NULL,
        [CSD_START]              DateTime               NULL,
        [CSD_CODE_CLIENT]        Int                NOT NULL,
        [CSD_CODE_CLIENT_NOTE]   NVarChar(512)          NULL,
        [CSD_USR]                NVarChar(512)      NOT NULL,
        CONSTRAINT [PK_IP.ClientStatDetailCache] PRIMARY KEY CLUSTERED ([CSD_SYS],[CSD_DISTR],[CSD_COMP])
);
GO
