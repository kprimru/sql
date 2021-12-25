﻿USE [SaleDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Client].[CompanyPhone]
(
        [ID]           UniqueIdentifier      NOT NULL,
        [ID_MASTER]    UniqueIdentifier          NULL,
        [ID_COMPANY]   UniqueIdentifier      NOT NULL,
        [ID_OFFICE]    UniqueIdentifier          NULL,
        [ID_TYPE]      UniqueIdentifier          NULL,
        [PHONE]        NVarChar(256)         NOT NULL,
        [PHONE_S]      NVarChar(128)         NOT NULL,
        [NOTE]         NVarChar(Max)         NOT NULL,
        [BDATE]        DateTime              NOT NULL,
        [EDATE]        DateTime                  NULL,
        [STATUS]       TinyInt               NOT NULL,
        [UPD_USER]     NVarChar(256)         NOT NULL,
        CONSTRAINT [PK_Client.CompanyPhone] PRIMARY KEY CLUSTERED ([ID]),
        CONSTRAINT [FK_Client.CompanyPhone(ID_TYPE)_Client.PhoneType(ID)] FOREIGN KEY  ([ID_TYPE]) REFERENCES [Client].[PhoneType] ([ID]),
        CONSTRAINT [FK_Client.CompanyPhone(ID_MASTER)_Client.CompanyPhone(ID)] FOREIGN KEY  ([ID_MASTER]) REFERENCES [Client].[CompanyPhone] ([ID]),
        CONSTRAINT [FK_Client.CompanyPhone(ID_COMPANY)_Client.Company(ID)] FOREIGN KEY  ([ID_COMPANY]) REFERENCES [Client].[Company] ([ID]),
        CONSTRAINT [FK_Client.CompanyPhone(ID_OFFICE)_Client.Office(ID)] FOREIGN KEY  ([ID_OFFICE]) REFERENCES [Client].[Office] ([ID])
);
GO
CREATE NONCLUSTERED INDEX [IX_Client.CompanyPhone(ID_COMPANY)+(ID,ID_OFFICE,ID_TYPE,PHONE,PHONE_S,NOTE)] ON [Client].[CompanyPhone] ([ID_COMPANY] ASC) INCLUDE ([ID], [ID_OFFICE], [ID_TYPE], [PHONE], [PHONE_S], [NOTE]);
CREATE NONCLUSTERED INDEX [IX_Client.CompanyPhone(ID_MASTER,STATUS)+(BDATE,UPD_USER)] ON [Client].[CompanyPhone] ([ID_MASTER] ASC, [STATUS] ASC) INCLUDE ([BDATE], [UPD_USER]);
CREATE NONCLUSTERED INDEX [IX_Client.CompanyPhone(PHONE_S)+(ID_COMPANY)] ON [Client].[CompanyPhone] ([PHONE_S] ASC) INCLUDE ([ID_COMPANY]);
CREATE NONCLUSTERED INDEX [IX_Client.CompanyPhone(STATUS,PHONE_S)+(ID_COMPANY)] ON [Client].[CompanyPhone] ([STATUS] ASC, [PHONE_S] ASC) INCLUDE ([ID_COMPANY]);
GO
