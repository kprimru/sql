USE [SaleDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Security].[LogonUsers]
(
        [ID]                UniqueIdentifier      NOT NULL,
        [SPID]              SmallInt              NOT NULL,
        [HOST_NAME]         NVarChar(256)         NOT NULL,
        [LOGIN_NAME]        NVarChar(256)         NOT NULL,
        [LOGIN_TIME]        DateTime              NOT NULL,
        [HOST_PROCESS_ID]   Int                   NOT NULL,
        [FLOGIN]            NVarChar(256)         NOT NULL,
        [USER_ID]           UniqueIdentifier      NOT NULL,
        CONSTRAINT [PK_LogonUsers] PRIMARY KEY CLUSTERED ([ID])
);GO
