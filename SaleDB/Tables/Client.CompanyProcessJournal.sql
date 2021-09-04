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
        CONSTRAINT [PK_CompanyProcessJournal] PRIMARY KEY CLUSTERED ([ID]),
        CONSTRAINT [FK_CompanyProcessJournal_OfficePersonal] FOREIGN KEY  ([ID_PERSONAL]) REFERENCES [Personal].[OfficePersonal] ([ID]),
        CONSTRAINT [FK_CompanyProcessJournal_Company] FOREIGN KEY  ([ID_COMPANY]) REFERENCES [Client].[Company] ([ID]),
        CONSTRAINT [FK_CompanyProcessJournal_Availability] FOREIGN KEY  ([ID_AVAILABILITY]) REFERENCES [Client].[Availability] ([ID])
);
GO
CREATE NONCLUSTERED INDEX [IX_PROCESS] ON [Client].[CompanyProcessJournal] ([TYPE] ASC, [ID_PERSONAL] ASC, [ID_AVAILABILITY] ASC, [DATE] ASC) INCLUDE ([ID_COMPANY]);
GO
