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
        CONSTRAINT [PK_CompanyArchive] PRIMARY KEY CLUSTERED ([ID]),
        CONSTRAINT [FK_CompanyArchive_Potential] FOREIGN KEY  ([ID_POTENTIAL]) REFERENCES [Client].[Potential] ([ID]),
        CONSTRAINT [FK_CompanyArchive_Availability] FOREIGN KEY  ([ID_AVAILABILITY]) REFERENCES [Client].[Availability] ([ID]),
        CONSTRAINT [FK_CompanyArchive_Month] FOREIGN KEY  ([ID_NEXT_MON]) REFERENCES [Common].[Month] ([ID]),
        CONSTRAINT [FK_CompanyArchive_Company] FOREIGN KEY  ([ID_COMPANY]) REFERENCES [Client].[Company] ([ID]),
        CONSTRAINT [FK_CompanyArchive_CompanyArchive] FOREIGN KEY  ([ID_MASTER]) REFERENCES [Client].[CompanyArchive] ([ID]),
        CONSTRAINT [FK_CompanyArchive_Character] FOREIGN KEY  ([ID_CHARACTER]) REFERENCES [Client].[Character] ([ID])
);
GO
CREATE NONCLUSTERED INDEX [IX_CompanyArchive_ID_COMPANY_STATUS] ON [Client].[CompanyArchive] ([ID_COMPANY] ASC, [STATUS] ASC) INCLUDE ([ID], [BDATE], [UPD_USER]);
CREATE NONCLUSTERED INDEX [IX_CompanyArchive_STATUS] ON [Client].[CompanyArchive] ([STATUS] ASC) INCLUDE ([ID], [ID_COMPANY], [BDATE], [UPD_USER]);
GO
