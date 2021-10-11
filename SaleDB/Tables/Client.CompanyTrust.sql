USE [SaleDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Client].[CompanyTrust]
(
        [ID]           UniqueIdentifier      NOT NULL,
        [ID_MASTER]    UniqueIdentifier          NULL,
        [ID_COMPANY]   UniqueIdentifier      NOT NULL,
        [ID_OFFICE]    UniqueIdentifier          NULL,
        [DATE]         DateTime              NOT NULL,
        [TRUST]        Bit                       NULL,
        [NOTE]         NVarChar(Max)         NOT NULL,
        [STATUS]       TinyInt               NOT NULL,
        [BDATE]        DateTime              NOT NULL,
        [EDATE]        DateTime                  NULL,
        [UPD_USER]     NVarChar(256)         NOT NULL,
        CONSTRAINT [PK_CompanyTrust] PRIMARY KEY CLUSTERED ([ID]),
        CONSTRAINT [FK_CompanyTrust_Company] FOREIGN KEY  ([ID_COMPANY]) REFERENCES [Client].[Company] ([ID]),
        CONSTRAINT [FK_CompanyTrust_Office] FOREIGN KEY  ([ID_OFFICE]) REFERENCES [Client].[Office] ([ID]),
        CONSTRAINT [FK_CompanyTrust_CompanyTrust] FOREIGN KEY  ([ID_MASTER]) REFERENCES [Client].[CompanyTrust] ([ID])
);GO
