USE [FirstInstall]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Book].[BookDelivery]
(
        [BDMS_ID]     UniqueIdentifier      NOT NULL,
        [BDMS_LAST]   DateTime              NOT NULL,
        CONSTRAINT [PK_BookDelivery] PRIMARY KEY CLUSTERED ([BDMS_ID])
);
GO
CREATE NONCLUSTERED INDEX [IX_BDMS_LAST] ON [Book].[BookDelivery] ([BDMS_LAST] DESC);
GO
