USE [FirstInstall]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Book].[BookPrice]
(
        [BPMS_ID]     UniqueIdentifier      NOT NULL,
        [BPMS_LAST]   DateTime                  NULL,
        CONSTRAINT [PK_BookPrice] PRIMARY KEY CLUSTERED ([BPMS_ID])
);
GO
CREATE NONCLUSTERED INDEX [IX_BPMS_LAST] ON [Book].[BookPrice] ([BPMS_LAST] DESC);
GO
