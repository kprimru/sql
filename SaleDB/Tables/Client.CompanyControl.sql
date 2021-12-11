USE [SaleDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Client].[CompanyControl]
(
        [ID]            UniqueIdentifier      NOT NULL,
        [ID_MASTER]     UniqueIdentifier          NULL,
        [ID_COMPANY]    UniqueIdentifier      NOT NULL,
        [DATE]          DateTime              NOT NULL,
        [NOTIFY_DATE]   SmallDateTime             NULL,
        [REMOVE_DATE]   DateTime                  NULL,
        [REMOVE_USER]   NVarChar(256)             NULL,
        [NOTE]          NVarChar(Max)         NOT NULL,
        [STATUS]        TinyInt               NOT NULL,
        [BDATE]         DateTime              NOT NULL,
        [EDATE]         DateTime                  NULL,
        [UPD_USER]      NVarChar(256)         NOT NULL,
        CONSTRAINT [PK_Client.CompanyControl] PRIMARY KEY CLUSTERED ([ID]),
        CONSTRAINT [FK_Client.CompanyControl(ID_MASTER)_Client.CompanyControl(ID)] FOREIGN KEY  ([ID_MASTER]) REFERENCES [Client].[CompanyControl] ([ID]),
        CONSTRAINT [FK_Client.CompanyControl(ID_COMPANY)_Client.Company(ID)] FOREIGN KEY  ([ID_COMPANY]) REFERENCES [Client].[Company] ([ID])
);
GO
CREATE NONCLUSTERED INDEX [IX_Client.CompanyControl(ID_COMPANY)] ON [Client].[CompanyControl] ([ID_COMPANY] ASC);
CREATE NONCLUSTERED INDEX [IX_Client.CompanyControl(ID_MASTER,STATUS)] ON [Client].[CompanyControl] ([ID_MASTER] ASC, [STATUS] ASC);
GO
