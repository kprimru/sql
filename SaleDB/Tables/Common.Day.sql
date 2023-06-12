USE [SaleDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Common].[Day]
(
        [ID]      UniqueIdentifier      NOT NULL,
        [NAME]    NVarChar(256)         NOT NULL,
        [SHORT]   NVarChar(64)          NOT NULL,
        [NUM]     TinyInt               NOT NULL,
        [LAST]    DateTime              NOT NULL,
        CONSTRAINT [PK_Common.Day] PRIMARY KEY CLUSTERED ([ID])
);
GO
CREATE NONCLUSTERED INDEX [IX_Common.Day(LAST)] ON [Common].[Day] ([LAST] ASC);
GO
