﻿USE [FirstInstall]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Distr].[Weight]
(
        [WGMS_ID]     UniqueIdentifier      NOT NULL,
        [WGMS_LAST]   DateTime              NOT NULL,
        CONSTRAINT [PK_Distr.Weight] PRIMARY KEY CLUSTERED ([WGMS_ID])
);
GO
CREATE NONCLUSTERED INDEX [IX_Distr.Weight(WGMS_LAST)] ON [Distr].[Weight] ([WGMS_LAST] DESC);
GO
