USE [FirstInstall]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Common].[Period]
(
        [PRMS_ID]     UniqueIdentifier      NOT NULL,
        [PRMS_LAST]   DateTime              NOT NULL,
        CONSTRAINT [PK_Common.Period] PRIMARY KEY CLUSTERED ([PRMS_ID])
);
GO
CREATE NONCLUSTERED INDEX [IX_Common.Period(PRMS_LAST)] ON [Common].[Period] ([PRMS_LAST] DESC);
GO
