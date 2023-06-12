USE [SaleDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Client].[CompanyArchive]
(
        [ID]                UniqueIdentifier      NOT NULL,
        [ID_MASTER]         UniqueIdentifier          NULL,
        [ID_COMPANY]        UniqueIdentifier      NOT NULL,
        [ID_POTENTIAL]      UniqueIdentifier          NULL,
        [ID_NEXT_MON]       UniqueIdentifier          NULL,
        [ID_AVAILABILITY]   UniqueIdentifier          NULL,
        [ID_CHARACTER]      UniqueIdentifier          NULL,
        [ID_PAY_CAT]        UniqueIdentifier          NULL,
        [STATUS]            TinyInt               NOT NULL,
        [BDATE]             DateTime              NOT NULL,
        [EDATE]             DateTime                  NULL,
        [UPD_USER]          NVarChar(256)         NOT NULL,
        CONSTRAINT [PK_Client.CompanyArchive] PRIMARY KEY CLUSTERED ([ID]),
        CONSTRAINT [FK_Client.CompanyArchive(ID_POTENTIAL)_Client.Potential(ID)] FOREIGN KEY  ([ID_POTENTIAL]) REFERENCES [Client].[Potential] ([ID]),
        CONSTRAINT [FK_Client.CompanyArchive(ID_AVAILABILITY)_Client.Availability(ID)] FOREIGN KEY  ([ID_AVAILABILITY]) REFERENCES [Client].[Availability] ([ID]),
        CONSTRAINT [FK_Client.CompanyArchive(ID_NEXT_MON)_Client.Month(ID)] FOREIGN KEY  ([ID_NEXT_MON]) REFERENCES [Common].[Month] ([ID]),
        CONSTRAINT [FK_Client.CompanyArchive(ID_COMPANY)_Client.Company(ID)] FOREIGN KEY  ([ID_COMPANY]) REFERENCES [Client].[Company] ([ID]),
        CONSTRAINT [FK_Client.CompanyArchive(ID_MASTER)_Client.CompanyArchive(ID)] FOREIGN KEY  ([ID_MASTER]) REFERENCES [Client].[CompanyArchive] ([ID]),
        CONSTRAINT [FK_Client.CompanyArchive(ID_CHARACTER)_Client.Character(ID)] FOREIGN KEY  ([ID_CHARACTER]) REFERENCES [Client].[Character] ([ID])
);
GO
CREATE NONCLUSTERED INDEX [IX_Client.CompanyArchive(ID_COMPANY,STATUS)+(ID,BDATE,UPD_USER)] ON [Client].[CompanyArchive] ([ID_COMPANY] ASC, [STATUS] ASC) INCLUDE ([ID], [BDATE], [UPD_USER]);
CREATE NONCLUSTERED INDEX [IX_Client.CompanyArchive(STATUS)+(ID,ID_COMPANY,BDATE,UPD_USER)] ON [Client].[CompanyArchive] ([STATUS] ASC) INCLUDE ([ID], [ID_COMPANY], [BDATE], [UPD_USER]);
GO
