USE [FirstInstall]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Clients].[Vendors]
(
        [VDMS_ID]     UniqueIdentifier      NOT NULL,
        [VDMS_LAST]   DateTime              NOT NULL,
        CONSTRAINT [PK_Vendors_1] PRIMARY KEY CLUSTERED ([VDMS_ID])
);
GO
CREATE NONCLUSTERED INDEX [IX_VDMS_LAST] ON [Clients].[Vendors] ([VDMS_LAST] DESC);
GO
