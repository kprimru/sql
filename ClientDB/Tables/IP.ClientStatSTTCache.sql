﻿USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [IP].[ClientStatSTTCache]
(
        [CSD_SYS]     SmallInt      NOT NULL,
        [CSD_DISTR]   Int           NOT NULL,
        [CSD_COMP]    SmallInt      NOT NULL,
        [CSD_START]   DateTime      NOT NULL,
        [CSD_END]     DateTime          NULL,
        CONSTRAINT [PK_IP.ClientStatSttCache] PRIMARY KEY CLUSTERED ([CSD_SYS],[CSD_DISTR],[CSD_COMP],[CSD_START])
);
GO
CREATE NONCLUSTERED INDEX [IX_IP.ClientStatSTTCache(CSD_START,CSD_DISTR,CSD_SYS,CSD_COMP)] ON [IP].[ClientStatSTTCache] ([CSD_START] ASC, [CSD_DISTR] ASC, [CSD_SYS] ASC, [CSD_COMP] ASC);
GO
