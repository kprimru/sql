USE [SaleDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Client].[CompanyPersonal]
(
        [ID]            UniqueIdentifier      NOT NULL,
        [ID_MASTER]     UniqueIdentifier          NULL,
        [ID_COMPANY]    UniqueIdentifier      NOT NULL,
        [ID_OFFICE]     UniqueIdentifier          NULL,
        [SURNAME]       NVarChar(256)         NOT NULL,
        [NAME]          NVarChar(256)         NOT NULL,
        [PATRON]        NVarChar(256)         NOT NULL,
        [ID_POSITION]   UniqueIdentifier          NULL,
        [NOTE]          NVarChar(Max)             NULL,
        [FIO]            AS ((isnull([SURNAME]+N' ',N'')+isnull([NAME]+N' ',N''))+isnull([PATRON],N'')) PERSISTED,
        [EMAIL]         NVarChar(512)             NULL,
        [MAILING]       Bit                       NULL,
        [OLD_ID]        UniqueIdentifier          NULL,
        [BDATE]         DateTime              NOT NULL,
        [EDATE]         DateTime                  NULL,
        [STATUS]        TinyInt               NOT NULL,
        [UPD_USER]      NVarChar(256)         NOT NULL,
        CONSTRAINT [PK_Client.CompanyPersonal] PRIMARY KEY CLUSTERED ([ID]),
        CONSTRAINT [FK_Client.CompanyPersonal(ID_OFFICE)_Client.Office(ID)] FOREIGN KEY  ([ID_OFFICE]) REFERENCES [Client].[Office] ([ID]),
        CONSTRAINT [FK_Client.CompanyPersonal(ID_POSITION)_Client.Position(ID)] FOREIGN KEY  ([ID_POSITION]) REFERENCES [Client].[Position] ([ID]),
        CONSTRAINT [FK_Client.CompanyPersonal(ID_MASTER)_Client.CompanyPersonal(ID)] FOREIGN KEY  ([ID_MASTER]) REFERENCES [Client].[CompanyPersonal] ([ID]),
        CONSTRAINT [FK_Client.CompanyPersonal(ID_COMPANY)_Client.Company(ID)] FOREIGN KEY  ([ID_COMPANY]) REFERENCES [Client].[Company] ([ID])
);
GO
CREATE NONCLUSTERED INDEX [IX_Client.CompanyPersonal(EMAIL,ID_COMPANY,STATUS)] ON [Client].[CompanyPersonal] ([EMAIL] ASC, [ID_COMPANY] ASC, [STATUS] ASC);
CREATE NONCLUSTERED INDEX [IX_Client.CompanyPersonal(ID_COMPANY)+(ID,ID_OFFICE,SURNAME,NAME,PATRON,ID_POSITION,NOTE)] ON [Client].[CompanyPersonal] ([ID_COMPANY] ASC) INCLUDE ([ID], [ID_OFFICE], [SURNAME], [NAME], [PATRON], [ID_POSITION], [NOTE]);
CREATE NONCLUSTERED INDEX [IX_Client.CompanyPersonal(ID_MASTER,STATUS)+(BDATE,UPD_USER)] ON [Client].[CompanyPersonal] ([ID_MASTER] ASC, [STATUS] ASC) INCLUDE ([BDATE], [UPD_USER]);
CREATE NONCLUSTERED INDEX [IX_Client.CompanyPersonal(STATUS,FIO,ID_COMPANY)] ON [Client].[CompanyPersonal] ([STATUS] ASC, [FIO] ASC, [ID_COMPANY] ASC);
CREATE NONCLUSTERED INDEX [IX_Client.CompanyPersonal(STATUS,NAME,SURNAME,PATRON,ID_COMPANY)] ON [Client].[CompanyPersonal] ([STATUS] ASC, [NAME] ASC, [SURNAME] ASC, [PATRON] ASC, [ID_COMPANY] ASC);
GO
