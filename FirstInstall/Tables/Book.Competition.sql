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
        CONSTRAINT [PK_Book.Competition] PRIMARY KEY CLUSTERED ([CPMS_ID])
);
GO
CREATE NONCLUSTERED INDEX [IX_Book.Competition(CPMS_LAST)] ON [Book].[Competition] ([CPMS_LAST] DESC);
GO
