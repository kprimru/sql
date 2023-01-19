USE [SaleDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Security].[ErrorLog]
(
        [ID]          UniqueIdentifier      NOT NULL,
        [DATE]        DateTime              NOT NULL,
        [USER_NAME]   NVarChar(256)         NOT NULL,
        [NUM]         Int                       NULL,
        [PROC_NAME]   NVarChar(256)             NULL,
        [MESSAGE]     NVarChar(4096)            NULL,
        CONSTRAINT [PK_Security.ErrorLog] PRIMARY KEY CLUSTERED ([ID])
);
GO
