USE [SaleDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Client].[CompanyProcessJournal]
(
        [ID]                UniqueIdentifier      NOT NULL,
        [ID_COMPANY]        UniqueIdentifier      NOT NULL,
        [DATE]              DateTime              NOT NULL,
        [DATE_S]             AS ([Common].[DateOf]([DATE])) PERSISTED,
        [TYPE]              Int                   NOT NULL,
        [ID_AVAILABILITY]   UniqueIdentifier          NULL,
        [ID_PERSONAL]       UniqueIdentifier          NULL,
        [ID_CHARACTER]      UniqueIdentifier          NULL,
        [MESSAGE]           NVarChar(1024)            NULL,
        [UPD_USER]          NVarChar(256)         NOT NULL,
        CONSTRAINT [PK_Client.CompanyProcessJournal] PRIMARY KEY CLUSTERED ([ID]),
        CONSTRAINT [FK_Client.CompanyProcessJournal(ID_PERSONAL)_Client.OfficePersonal(ID)] FOREIGN KEY  ([ID_PERSONAL]) REFERENCES [Personal].[OfficePersonal] ([ID]),
        CONSTRAINT [FK_Client.CompanyProcessJournal(ID_COMPANY)_Client.Company(ID)] FOREIGN KEY  ([ID_COMPANY]) REFERENCES [Client].[Company] ([ID]),
        CONSTRAINT [FK_Client.CompanyProcessJournal(ID_AVAILABILITY)_Client.Availability(ID)] FOREIGN KEY  ([ID_AVAILABILITY]) REFERENCES [Client].[Availability] ([ID])
);
GO
CREATE NONCLUSTERED INDEX [IX_Client.CompanyProcessJournal(TYPE,ID_PERSONAL,ID_AVAILABILITY,DATE)+(ID_COMPANY)] ON [Client].[CompanyProcessJournal] ([TYPE] ASC, [ID_PERSONAL] ASC, [ID_AVAILABILITY] ASC, [DATE] ASC) INCLUDE ([ID_COMPANY]);
GO
