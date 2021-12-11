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
        CONSTRAINT [PK_Client.CompanyProcess] PRIMARY KEY CLUSTERED ([ID]),
        CONSTRAINT [FK_Client.CompanyProcess(ID_PERSONAL)_Client.OfficePersonal(ID)] FOREIGN KEY  ([ID_PERSONAL]) REFERENCES [Personal].[OfficePersonal] ([ID]),
        CONSTRAINT [FK_Client.CompanyProcess(ID_COMPANY)_Client.Company(ID)] FOREIGN KEY  ([ID_COMPANY]) REFERENCES [Client].[Company] ([ID])
);
GO
CREATE NONCLUSTERED INDEX [IX_Client.CompanyProcess(BDATE)+(ID_COMPANY,ID_PERSONAL)] ON [Client].[CompanyProcess] ([BDATE] ASC) INCLUDE ([ID_COMPANY], [ID_PERSONAL]);
CREATE NONCLUSTERED INDEX [IX_Client.CompanyProcess(EDATE)+(ID_COMPANY,ID_PERSONAL)] ON [Client].[CompanyProcess] ([EDATE] ASC) INCLUDE ([ID_COMPANY], [ID_PERSONAL]);
CREATE NONCLUSTERED INDEX [IX_Client.CompanyProcess(ID_COMPANY)+INCL] ON [Client].[CompanyProcess] ([ID_COMPANY] ASC) INCLUDE ([ID], [ID_PERSONAL], [PROCESS_TYPE], [BDATE], [EDATE], [ASSIGN_DATE], [ASSIGN_USER], [RETURN_DATE]);
CREATE NONCLUSTERED INDEX [IX_Client.CompanyProcess(ID_PERSONAL,PROCESS_TYPE,EDATE)+(ID_COMPANY)] ON [Client].[CompanyProcess] ([ID_PERSONAL] ASC, [PROCESS_TYPE] ASC, [EDATE] ASC) INCLUDE ([ID_COMPANY]);
CREATE NONCLUSTERED INDEX [IX_Client.CompanyProcess(PROCESS_TYPE,EDATE,BDATE)+(ID_COMPANY,ID_PERSONAL)] ON [Client].[CompanyProcess] ([PROCESS_TYPE] ASC, [EDATE] ASC, [BDATE] ASC) INCLUDE ([ID_COMPANY], [ID_PERSONAL]);
GO
