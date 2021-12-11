USE [SaleDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Client].[Call]
(
        [ID]            UniqueIdentifier      NOT NULL,
        [ID_MASTER]     UniqueIdentifier          NULL,
        [ID_COMPANY]    UniqueIdentifier      NOT NULL,
        [ID_OFFICE]     UniqueIdentifier          NULL,
        [ID_PERSONAL]   UniqueIdentifier      NOT NULL,
        [CL_PERSONAL]   NVarChar(1024)        NOT NULL,
        [DATE]          DateTime              NOT NULL,
        [DATE_S]         AS ([Common].[DateOf]([DATE])) PERSISTED,
        [NOTE]          NVarChar(Max)         NOT NULL,
        [STATUS]        TinyInt               NOT NULL,
        [BDATE]         DateTime              NOT NULL,
        [EDATE]         DateTime                  NULL,
        [UPD_USER]      NVarChar(256)         NOT NULL,
        [CONTROL]       Bit                   NOT NULL,
        [DUTY]          Bit                       NULL,
        CONSTRAINT [PK_Client.Call] PRIMARY KEY CLUSTERED ([ID]),
        CONSTRAINT [FK_Client.Call(ID_OFFICE)_Client.Office(ID)] FOREIGN KEY  ([ID_OFFICE]) REFERENCES [Client].[Office] ([ID]),
        CONSTRAINT [FK_Client.Call(ID_MASTER)_Client.Call(ID)] FOREIGN KEY  ([ID_MASTER]) REFERENCES [Client].[Call] ([ID]),
        CONSTRAINT [FK_Client.Call(ID_PERSONAL)_Client.OfficePersonal(ID)] FOREIGN KEY  ([ID_PERSONAL]) REFERENCES [Personal].[OfficePersonal] ([ID]),
        CONSTRAINT [FK_Client.Call(ID_COMPANY)_Client.Company(ID)] FOREIGN KEY  ([ID_COMPANY]) REFERENCES [Client].[Company] ([ID])
);
GO
CREATE NONCLUSTERED INDEX [IX_Client.Call(ID_COMPANY)] ON [Client].[Call] ([ID_COMPANY] ASC);
CREATE NONCLUSTERED INDEX [IX_Client.Call(ID_MASTER,STATUS)] ON [Client].[Call] ([ID_MASTER] ASC, [STATUS] ASC);
CREATE NONCLUSTERED INDEX [IX_Client.Call(STATUS,DATE_S)+(ID_COMPANY,ID_PERSONAL,NOTE,DATE,CL_PERSONAL)] ON [Client].[Call] ([STATUS] ASC, [DATE_S] ASC) INCLUDE ([ID_COMPANY], [ID_PERSONAL], [NOTE], [DATE], [CL_PERSONAL]);
GO
