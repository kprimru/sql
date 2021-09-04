USE [SaleDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Common].[Locks]
(
        [ID]           UniqueIdentifier      NOT NULL,
        [DATA]         VarChar(64)           NOT NULL,
        [REC]          VarChar(512)              NULL,
        [REC_STR]      VarChar(512)              NULL,
        [LOCK_TIME]    DateTime              NOT NULL,
        [LOCK_SPID]    Int                   NOT NULL,
        [LOCK_LOGIN]   NVarChar(256)         NOT NULL,
        [LOCK_HOST]    NVarChar(256)         NOT NULL,
        [LOGIN_TIME]   DateTime              NOT NULL,
        CONSTRAINT [PK_Locks] PRIMARY KEY CLUSTERED ([ID])
);
GO
CREATE NONCLUSTERED INDEX [IX_DATA] ON [Common].[Locks] ([DATA] ASC, [REC] ASC) INCLUDE ([LOCK_SPID], [LOCK_LOGIN], [LOCK_HOST], [LOGIN_TIME]);
GO
