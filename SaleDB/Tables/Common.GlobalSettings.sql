USE [SaleDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Common].[GlobalSettings]
(
        [ID]        UniqueIdentifier      NOT NULL,
        [NAME]      NVarChar(512)         NOT NULL,
        [CAPTION]   NVarChar(512)         NOT NULL,
        [VALUE]     NVarChar(2048)        NOT NULL,
        [NOTE]      NVarChar(Max)         NOT NULL,
        [LAST]      DateTime              NOT NULL,
        CONSTRAINT [PK_Common.GlobalSettings] PRIMARY KEY CLUSTERED ([ID])
);
GO
CREATE NONCLUSTERED INDEX [IX_Common.GlobalSettings(LAST)] ON [Common].[GlobalSettings] ([LAST] ASC);
GO
