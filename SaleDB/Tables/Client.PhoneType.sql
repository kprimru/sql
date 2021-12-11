USE [SaleDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Client].[PhoneType]
(
        [ID]      UniqueIdentifier      NOT NULL,
        [NAME]    NVarChar(256)         NOT NULL,
        [SHORT]   NVarChar(128)         NOT NULL,
        [LAST]    DateTime              NOT NULL,
        CONSTRAINT [PK_Client.PhoneType] PRIMARY KEY CLUSTERED ([ID])
);
GO
CREATE NONCLUSTERED INDEX [IX_Client.PhoneType(LAST)] ON [Client].[PhoneType] ([LAST] ASC);
GO
