USE [FirstInstall]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Book].[BookBonus]
(
        [BBMS_ID]     UniqueIdentifier      NOT NULL,
        [BBMS_LAST]   DateTime              NOT NULL,
        CONSTRAINT [PK_BookBonus] PRIMARY KEY CLUSTERED ([BBMS_ID])
);
GO
CREATE NONCLUSTERED INDEX [IX_BBMS_LAST] ON [Book].[BookBonus] ([BBMS_LAST] DESC);
GO
