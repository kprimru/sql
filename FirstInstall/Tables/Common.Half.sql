USE [FirstInstall]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Common].[Half]
(
        [HLFMS_ID]     UniqueIdentifier      NOT NULL,
        [HLFMS_LAST]   DateTime              NOT NULL,
        CONSTRAINT [PK_Common.Half] PRIMARY KEY CLUSTERED ([HLFMS_ID])
);
GO
CREATE NONCLUSTERED INDEX [IX_Common.Half(HLFMS_LAST)] ON [Common].[Half] ([HLFMS_LAST] DESC);
GO
