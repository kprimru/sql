USE [FirstInstall]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Personal].[Department]
(
        [DPMS_ID]     UniqueIdentifier      NOT NULL,
        [DPMS_LAST]   DateTime              NOT NULL,
        CONSTRAINT [PK_Department_1] PRIMARY KEY CLUSTERED ([DPMS_ID])
);
GO
CREATE NONCLUSTERED INDEX [IX_DPMS_LAST] ON [Personal].[Department] ([DPMS_LAST] DESC);
GO
