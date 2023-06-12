USE [SaleDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Common].[Words]
(
        [ID]     UniqueIdentifier      NOT NULL,
        [NAME]   NVarChar(128)         NOT NULL,
        [TYPE]   TinyInt               NOT NULL,
        [LAST]   DateTime              NOT NULL,
        CONSTRAINT [PK_Common.Words] PRIMARY KEY NONCLUSTERED ([ID])
);
GO
CREATE UNIQUE CLUSTERED INDEX [UC_Common.Words(NAME)] ON [Common].[Words] ([NAME] ASC);
GO
