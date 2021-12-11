USE [SaleDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Security].[CompanyList]
(
        [ID]            UniqueIdentifier      NOT NULL,
        [USER_NAME]     NVarChar(256)         NOT NULL,
        [TYPE]          NVarChar(64)          NOT NULL,
        [V_ALL]         Bit                   NOT NULL,
        [V_SALE_MAN]    Bit                   NOT NULL,
        [V_SALE_ALL]    Bit                   NOT NULL,
        [V_SALE]        Bit                   NOT NULL,
        [V_PHONE_MAN]   Bit                   NOT NULL,
        [V_PHONE]       Bit                   NOT NULL,
        [V_RIVAL]       Bit                   NOT NULL,
        CONSTRAINT [PK_Security.CompanyList] PRIMARY KEY CLUSTERED ([ID])
);GO
