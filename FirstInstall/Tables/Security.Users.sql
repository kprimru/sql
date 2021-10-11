USE [FirstInstall]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Security].[Users]
(
        [USMS_ID]     UniqueIdentifier      NOT NULL,
        [USMS_LAST]   DateTime              NOT NULL,
        CONSTRAINT [PK_Users] PRIMARY KEY CLUSTERED ([USMS_ID])
);
GO
CREATE NONCLUSTERED INDEX [IX_USMS_LAST] ON [Security].[Users] ([USMS_LAST] DESC);
GO
