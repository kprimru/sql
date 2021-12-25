USE [FirstInstall]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Book].[Competition]
(
        [CPMS_ID]     UniqueIdentifier      NOT NULL,
        [CPMS_LAST]   DateTime              NOT NULL,
        CONSTRAINT [PK_Competition] PRIMARY KEY CLUSTERED ([CPMS_ID])
);
GO
CREATE NONCLUSTERED INDEX [IX_CPMS_LAST] ON [Book].[Competition] ([CPMS_LAST] DESC);
GO
