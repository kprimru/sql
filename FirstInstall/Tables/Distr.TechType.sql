USE [FirstInstall]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Distr].[TechType]
(
        [TTMS_ID]     UniqueIdentifier      NOT NULL,
        [TTMS_LAST]   DateTime              NOT NULL,
        CONSTRAINT [PK_TechType_1] PRIMARY KEY CLUSTERED ([TTMS_ID])
);
GO
CREATE NONCLUSTERED INDEX [IX_TTMS_LAST] ON [Distr].[TechType] ([TTMS_LAST] DESC);
GO
