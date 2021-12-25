USE [FirstInstall]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Personal].[Personals]
(
        [PERMS_ID]     UniqueIdentifier      NOT NULL,
        [PERMS_LAST]   DateTime              NOT NULL,
        CONSTRAINT [PK_Personals_1] PRIMARY KEY CLUSTERED ([PERMS_ID])
);
GO
CREATE NONCLUSTERED INDEX [IX_PERMS_LAST] ON [Personal].[Personals] ([PERMS_LAST] DESC);
GO
