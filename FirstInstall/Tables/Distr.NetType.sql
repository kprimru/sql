﻿USE [FirstInstall]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Distr].[NetType]
(
        [NTMS_ID]     UniqueIdentifier      NOT NULL,
        [NTMS_LAST]   DateTime              NOT NULL,
        CONSTRAINT [PK_Distr.NetType] PRIMARY KEY CLUSTERED ([NTMS_ID])
);
GO
CREATE NONCLUSTERED INDEX [IX_Distr.NetType(NTMS_LAST)] ON [Distr].[NetType] ([NTMS_LAST] DESC);
GO
