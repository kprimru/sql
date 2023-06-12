USE [SaleDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Client].[CompanyDemo]
(
        [ID]           UniqueIdentifier      NOT NULL,
        [ID_MASTER]    UniqueIdentifier          NULL,
        [ID_COMPANY]   UniqueIdentifier      NOT NULL,
        [ID_OFFICE]    UniqueIdentifier          NULL,
        [DATE]         SmallDateTime             NULL,
        [NOTE]         NVarChar(Max)             NULL,
        [STATUS]       TinyInt               NOT NULL,
        [BDATE]        DateTime              NOT NULL,
        [EDATE]        DateTime                  NULL,
        [UPD_USER]     NVarChar(256)         NOT NULL,
        CONSTRAINT [PK_Client.CompanyDemo] PRIMARY KEY CLUSTERED ([ID]),
        CONSTRAINT [FK_Client.CompanyDemo(ID_COMPANY)_Client.Company(ID)] FOREIGN KEY  ([ID_COMPANY]) REFERENCES [Client].[Company] ([ID]),
        CONSTRAINT [FK_Client.CompanyDemo(ID_OFFICE)_Client.Office(ID)] FOREIGN KEY  ([ID_OFFICE]) REFERENCES [Client].[Office] ([ID]),
        CONSTRAINT [FK_Client.CompanyDemo(ID_MASTER)_Client.CompanyDemo(ID)] FOREIGN KEY  ([ID_MASTER]) REFERENCES [Client].[CompanyDemo] ([ID])
);
GO
CREATE NONCLUSTERED INDEX [IX_Client.CompanyDemo(ID_COMPANY)] ON [Client].[CompanyDemo] ([ID_COMPANY] ASC);
CREATE NONCLUSTERED INDEX [IX_Client.CompanyDemo(ID_MASTER,STATUS)+(BDATE,UPD_USER)] ON [Client].[CompanyDemo] ([ID_MASTER] ASC, [STATUS] ASC) INCLUDE ([BDATE], [UPD_USER]);
GO
