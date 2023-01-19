USE [SaleDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Security].[Users]
(
        [ID]       UniqueIdentifier      NOT NULL,
        [LOGIN]    NVarChar(256)         NOT NULL,
        [NAME]     NVarChar(256)         NOT NULL,
        [TYPE]     TinyInt               NOT NULL,
        [STATUS]   TinyInt               NOT NULL,
        [LAST]     DateTime              NOT NULL,
        CONSTRAINT [PK_Security.Users] PRIMARY KEY CLUSTERED ([ID])
);
GO
