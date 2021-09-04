USE [SaleDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Client].[CompanyProcess]
(
        [ID]             UniqueIdentifier      NOT NULL,
        [ID_COMPANY]     UniqueIdentifier      NOT NULL,
        [ID_PERSONAL]    UniqueIdentifier      NOT NULL,
        [PROCESS_TYPE]   NVarChar(128)         NOT NULL,
        [BDATE]          SmallDateTime         NOT NULL,
        [EDATE]          SmallDateTime             NULL,
        [ASSIGN_DATE]    DateTime              NOT NULL,
        [ASSIGN_USER]    NVarChar(256)         NOT NULL,
        [RETURN_DATE]    DateTime                  NULL,
        [RETURN_USER]    NVarChar(256)             NULL,
        CONSTRAINT [PK_CompanyProcess] PRIMARY KEY CLUSTERED ([ID]),
        CONSTRAINT [FK_CompanyProcess_OfficePersonal] FOREIGN KEY  ([ID_PERSONAL]) REFERENCES [Personal].[OfficePersonal] ([ID]),
        CONSTRAINT [FK_CompanyProcess_Company] FOREIGN KEY  ([ID_COMPANY]) REFERENCES [Client].[Company] ([ID])
);
GO
CREATE NONCLUSTERED INDEX [IX_COMPANY] ON [Client].[CompanyProcess] ([ID_COMPANY] ASC) INCLUDE ([ID], [ID_PERSONAL], [PROCESS_TYPE], [BDATE], [EDATE], [ASSIGN_DATE], [ASSIGN_USER], [RETURN_DATE]);
CREATE NONCLUSTERED INDEX [IX_CompanyProcess__BDATE] ON [Client].[CompanyProcess] ([BDATE] ASC) INCLUDE ([ID_COMPANY], [ID_PERSONAL]);
CREATE NONCLUSTERED INDEX [IX_CompanyProcess__EDATE] ON [Client].[CompanyProcess] ([EDATE] ASC) INCLUDE ([ID_COMPANY], [ID_PERSONAL]);
CREATE NONCLUSTERED INDEX [IX_CompanyProcess_ID_PERSONAL_PROCESS_TYPE_EDATE] ON [Client].[CompanyProcess] ([ID_PERSONAL] ASC, [PROCESS_TYPE] ASC, [EDATE] ASC) INCLUDE ([ID_COMPANY]);
CREATE NONCLUSTERED INDEX [IX_CompanyProcess_PROCESS_TYPE_EDATE_BDATE] ON [Client].[CompanyProcess] ([PROCESS_TYPE] ASC, [EDATE] ASC, [BDATE] ASC) INCLUDE ([ID_COMPANY], [ID_PERSONAL]);
GO
