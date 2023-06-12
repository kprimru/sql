USE [SaleDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Client].[Office]
(
        [ID]           UniqueIdentifier      NOT NULL,
        [ID_MASTER]    UniqueIdentifier          NULL,
        [ID_COMPANY]   UniqueIdentifier      NOT NULL,
        [SHORT]        NVarChar(256)             NULL,
        [NAME]         NVarChar(896)         NOT NULL,
        [MAIN]         Bit                   NOT NULL,
        [BDATE]        DateTime              NOT NULL,
        [EDATE]        DateTime                  NULL,
        [STATUS]       TinyInt               NOT NULL,
        [OLD_ID]       UniqueIdentifier          NULL,
        [UPD_USER]     NVarChar(256)         NOT NULL,
        CONSTRAINT [PK_Client.Office] PRIMARY KEY CLUSTERED ([ID]),
        CONSTRAINT [FK_Client.Office(ID_MASTER)_Client.Office(ID)] FOREIGN KEY  ([ID_MASTER]) REFERENCES [Client].[Office] ([ID]),
        CONSTRAINT [FK_Client.Office(ID_COMPANY)_Client.Company(ID)] FOREIGN KEY  ([ID_COMPANY]) REFERENCES [Client].[Company] ([ID])
);
GO
CREATE NONCLUSTERED INDEX [IX_Client.Office(ID_COMPANY,STATUS)+(ID,SHORT,NAME)] ON [Client].[Office] ([ID_COMPANY] ASC, [STATUS] ASC) INCLUDE ([ID], [SHORT], [NAME]);
CREATE NONCLUSTERED INDEX [IX_Client.Office(ID_MASTER,STATUS)+(BDATE,UPD_USER)] ON [Client].[Office] ([ID_MASTER] ASC, [STATUS] ASC) INCLUDE ([BDATE], [UPD_USER]);
CREATE NONCLUSTERED INDEX [IX_Client.Office(STATUS)+(ID,ID_COMPANY)] ON [Client].[Office] ([STATUS] ASC) INCLUDE ([ID], [ID_COMPANY]);
GO
