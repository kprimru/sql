USE [SaleDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Sale].[SaleCompanyData]
(
        [ID]         UniqueIdentifier      NOT NULL,
        [ID_SALE]    UniqueIdentifier      NOT NULL,
        [INN]        NVarChar(64)          NOT NULL,
        [STREET]     UniqueIdentifier          NULL,
        [HOME]       NVarChar(128)             NULL,
        [ROOM]       NVarChar(128)             NULL,
        [CONTRACT]   NVarChar(128)             NULL,
        CONSTRAINT [PK_SaleCompanyData] PRIMARY KEY CLUSTERED ([ID]),
        CONSTRAINT [FK_SaleCompanyData_SaleCompany] FOREIGN KEY  ([ID_SALE]) REFERENCES [Sale].[SaleCompany] ([ID])
);GO
