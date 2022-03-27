USE [SaleDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Client].[CompanyRival]
(
        [ID]           UniqueIdentifier      NOT NULL,
        [ID_MASTER]    UniqueIdentifier          NULL,
        [ID_COMPANY]   UniqueIdentifier      NOT NULL,
        [ID_OFFICE]    UniqueIdentifier          NULL,
        [ID_RIVAL]     UniqueIdentifier      NOT NULL,
        [ID_VENDOR]    UniqueIdentifier          NULL,
        [INFO_DATE]    SmallDateTime             NULL,
        [NOTE]         NVarChar(Max)             NULL,
        [ACTIVE]       Bit                   NOT NULL,
        [STATUS]       TinyInt               NOT NULL,
        [BDATE]        DateTime              NOT NULL,
        [EDATE]        DateTime                  NULL,
        [UPD_USER]     NVarChar(256)         NOT NULL,
        CONSTRAINT [PK_Client.CompanyRival] PRIMARY KEY CLUSTERED ([ID]),
        CONSTRAINT [FK_Client.CompanyRival(ID_COMPANY)_Client.Company(ID)] FOREIGN KEY  ([ID_COMPANY]) REFERENCES [Client].[Company] ([ID]),
        CONSTRAINT [FK_Client.CompanyRival(ID_OFFICE)_Client.Office(ID)] FOREIGN KEY  ([ID_OFFICE]) REFERENCES [Client].[Office] ([ID]),
        CONSTRAINT [FK_Client.CompanyRival(ID_MASTER)_Client.CompanyRival(ID)] FOREIGN KEY  ([ID_MASTER]) REFERENCES [Client].[CompanyRival] ([ID]),
        CONSTRAINT [FK_Client.CompanyRival(ID_RIVAL)_Client.RivalSystem(ID)] FOREIGN KEY  ([ID_RIVAL]) REFERENCES [Client].[RivalSystem] ([ID])
);
GO
CREATE NONCLUSTERED INDEX [IX_Client.CompanyRival(ID_COMPANY)+(ID,ID_OFFICE,ID_RIVAL,INFO_DATE,NOTE,ACTIVE)] ON [Client].[CompanyRival] ([ID_COMPANY] ASC) INCLUDE ([ID], [ID_OFFICE], [ID_RIVAL], [INFO_DATE], [NOTE], [ACTIVE]);
CREATE NONCLUSTERED INDEX [IX_Client.CompanyRival(ID_MASTER,STATUS)+(BDATE,UPD_USER)] ON [Client].[CompanyRival] ([ID_MASTER] ASC, [STATUS] ASC) INCLUDE ([BDATE], [UPD_USER]);
CREATE NONCLUSTERED INDEX [IX_Client.CompanyRival(ID_RIVAL,ID_COMPANY)] ON [Client].[CompanyRival] ([ID_RIVAL] ASC, [ID_COMPANY] ASC);
CREATE NONCLUSTERED INDEX [IX_Client.CompanyRival(ID_VENDOR,ID_COMPANY)] ON [Client].[CompanyRival] ([ID_VENDOR] ASC, [ID_COMPANY] ASC);
GO
