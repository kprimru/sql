USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ClientContact]
(
        [ID]          UniqueIdentifier      NOT NULL,
        [ID_MASTER]   UniqueIdentifier          NULL,
        [ID_CLIENT]   Int                   NOT NULL,
        [DATE]        SmallDateTime         NOT NULL,
        [PERSONAL]    NVarChar(256)         NOT NULL,
        [SURNAME]     NVarChar(256)         NOT NULL,
        [NAME]        NVarChar(256)         NOT NULL,
        [PATRON]      NVarChar(256)         NOT NULL,
        [POSITION]    NVarChar(512)         NOT NULL,
        [ID_TYPE]     UniqueIdentifier      NOT NULL,
        [CATEGORY]    char(1)               NOT NULL,
        [NOTE]        NVarChar(Max)         NOT NULL,
        [PROBLEM]     NVarChar(Max)         NOT NULL,
        [STATUS]      TinyInt               NOT NULL,
        [UPD_DATE]    DateTime              NOT NULL,
        [UPD_USER]    NVarChar(256)         NOT NULL,
        CONSTRAINT [PK_dbo.ClientContact] PRIMARY KEY NONCLUSTERED ([ID]),
        CONSTRAINT [FK_dbo.ClientContact(ID_CLIENT)_dbo.ClientTable(ClientID)] FOREIGN KEY  ([ID_CLIENT]) REFERENCES [dbo].[ClientTable] ([ClientID]),
        CONSTRAINT [FK_dbo.ClientContact(ID_TYPE)_dbo.ClientContactType(ID)] FOREIGN KEY  ([ID_TYPE]) REFERENCES [dbo].[ClientContactType] ([ID])
);
GO
CREATE CLUSTERED INDEX [IC_dbo.ClientContact(ID_CLIENT,STATUS,DATE)] ON [dbo].[ClientContact] ([ID_CLIENT] ASC, [STATUS] ASC, [DATE] ASC);
CREATE NONCLUSTERED INDEX [IX_dbo.ClientContact(DATE,STATUS)+(ID_CLIENT,PERSONAL,NOTE,UPD_USER)] ON [dbo].[ClientContact] ([DATE] ASC, [STATUS] ASC) INCLUDE ([ID_CLIENT], [PERSONAL], [NOTE], [UPD_USER]);
CREATE NONCLUSTERED INDEX [IX_dbo.ClientContact(ID,UPD_DATE)+(UPD_USER)] ON [dbo].[ClientContact] ([ID] ASC, [UPD_DATE] ASC) INCLUDE ([UPD_USER]);
CREATE NONCLUSTERED INDEX [IX_dbo.ClientContact(ID_MASTER,UPD_DATE)+(UPD_USER)] ON [dbo].[ClientContact] ([ID_MASTER] ASC, [UPD_DATE] ASC) INCLUDE ([UPD_USER]);
CREATE NONCLUSTERED INDEX [IX_dbo.ClientContact(PERSONAL,DATE)] ON [dbo].[ClientContact] ([PERSONAL] ASC, [DATE] ASC);
GO
