﻿USE [FirstInstall]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Distr].[Hosts]
(
        [HSTMS_ID]     UniqueIdentifier      NOT NULL,
        [HSTMS_LAST]   DateTime              NOT NULL,
        CONSTRAINT [PK_Distr.Hosts] PRIMARY KEY CLUSTERED ([HSTMS_ID])
);
GO
CREATE NONCLUSTERED INDEX [IX_Distr.Hosts(HSTMS_LAST)] ON [Distr].[Hosts] ([HSTMS_LAST] DESC);
GO
