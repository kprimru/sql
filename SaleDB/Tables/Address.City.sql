USE [SaleDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Address].[City]
(
        [ID]        UniqueIdentifier      NOT NULL,
        [NAME]      NVarChar(512)         NOT NULL,
        [PREFIX]    NVarChar(64)          NOT NULL,
        [PHONE]     NVarChar(64)          NOT NULL,
        [DISPLAY]   Bit                       NULL,
        [LAST]      DateTime              NOT NULL,
        CONSTRAINT [PK_Address.City] PRIMARY KEY CLUSTERED ([ID])
);
GO
CREATE NONCLUSTERED INDEX [IX_Address.City(LAST)] ON [Address].[City] ([LAST] ASC);
GO
