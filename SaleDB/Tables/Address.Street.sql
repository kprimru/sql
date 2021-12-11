USE [SaleDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Address].[Street]
(
        [ID]        UniqueIdentifier      NOT NULL,
        [NAME]      NVarChar(512)         NOT NULL,
        [PREFIX]    NVarChar(64)          NOT NULL,
        [SUFFIX]    NVarChar(64)          NOT NULL,
        [ID_CITY]   UniqueIdentifier          NULL,
        [LAST]      DateTime              NOT NULL,
        CONSTRAINT [PK_Address.Street] PRIMARY KEY CLUSTERED ([ID]),
        CONSTRAINT [FK_Address.Street(ID_CITY)_Address.City(ID)] FOREIGN KEY  ([ID_CITY]) REFERENCES [Address].[City] ([ID])
);
GO
CREATE NONCLUSTERED INDEX [IX_Address.Street(LAST)] ON [Address].[Street] ([LAST] ASC);
GO
