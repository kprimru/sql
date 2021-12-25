USE [FirstInstall]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Distr].[Systems]
(
        [SYSMS_ID]     UniqueIdentifier      NOT NULL,
        [SYSMS_LAST]   DateTime              NOT NULL,
        CONSTRAINT [PK_Systems_1] PRIMARY KEY CLUSTERED ([SYSMS_ID])
);
GO
CREATE NONCLUSTERED INDEX [IX_SYSMS_LAST] ON [Distr].[Systems] ([SYSMS_LAST] DESC);
GO
