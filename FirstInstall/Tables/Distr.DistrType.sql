USE [FirstInstall]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Distr].[DistrType]
(
        [DTMS_ID]     UniqueIdentifier      NOT NULL,
        [DTMS_LAST]   DateTime              NOT NULL,
        CONSTRAINT [PK_DistrType_1] PRIMARY KEY CLUSTERED ([DTMS_ID])
);
GO
CREATE NONCLUSTERED INDEX [IX_DTMS_LAST] ON [Distr].[DistrType] ([DTMS_LAST] DESC);
GO
