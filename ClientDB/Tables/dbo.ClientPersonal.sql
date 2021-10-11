USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ClientPersonal]
(
        [CP_ID]           UniqueIdentifier      NOT NULL,
        [CP_ID_CLIENT]    Int                   NOT NULL,
        [CP_ID_ADDRESS]   UniqueIdentifier          NULL,
        [CP_ID_TYPE]      UniqueIdentifier          NULL,
        [CP_SURNAME]      VarChar(250)          NOT NULL,
        [CP_NAME]         VarChar(250)          NOT NULL,
        [CP_PATRON]       VarChar(250)          NOT NULL,
        [CP_POS]          VarChar(150)              NULL,
        [CP_NOTE]         VarChar(Max)              NULL,
        [CP_EMAIL]        VarChar(50)               NULL,
        [CP_PHONE]        VarChar(150)              NULL,
        [CP_MAP]          varbinary                 NULL,
        [CP_FAX]          VarChar(150)              NULL,
        [CP_PHONE_S]      VarChar(150)              NULL,
        CONSTRAINT [PK_dbo.ClientPersonal] PRIMARY KEY CLUSTERED ([CP_ID]),
        CONSTRAINT [FK_dbo.ClientPersonal(CP_ID_ADDRESS)_dbo.ClientAddress(CA_ID)] FOREIGN KEY  ([CP_ID_ADDRESS]) REFERENCES [dbo].[ClientAddress] ([CA_ID]),
        CONSTRAINT [FK_dbo.ClientPersonal(CP_ID_CLIENT)_dbo.ClientTable(ClientID)] FOREIGN KEY  ([CP_ID_CLIENT]) REFERENCES [dbo].[ClientTable] ([ClientID]),
        CONSTRAINT [FK_dbo.ClientPersonal(CP_ID_TYPE)_dbo.ClientPersonalType(CPT_ID)] FOREIGN KEY  ([CP_ID_TYPE]) REFERENCES [dbo].[ClientPersonalType] ([CPT_ID])
);
GO
CREATE NONCLUSTERED INDEX [IX_dbo.ClientPersonal(CP_ID_CLIENT)+INCL] ON [dbo].[ClientPersonal] ([CP_ID_CLIENT] ASC) INCLUDE ([CP_ID_TYPE], [CP_SURNAME], [CP_NAME], [CP_PATRON], [CP_POS], [CP_NOTE], [CP_EMAIL], [CP_PHONE], [CP_PHONE_S], [CP_FAX]);
CREATE NONCLUSTERED INDEX [IX_dbo.ClientPersonal(CP_NAME)+(CP_ID_CLIENT)] ON [dbo].[ClientPersonal] ([CP_NAME] ASC) INCLUDE ([CP_ID_CLIENT]);
CREATE NONCLUSTERED INDEX [IX_dbo.ClientPersonal(CP_PATRON)+(CP_ID_CLIENT)] ON [dbo].[ClientPersonal] ([CP_PATRON] ASC) INCLUDE ([CP_ID_CLIENT]);
CREATE NONCLUSTERED INDEX [IX_dbo.ClientPersonal(CP_POS)+(CP_ID_CLIENT)] ON [dbo].[ClientPersonal] ([CP_POS] ASC) INCLUDE ([CP_ID_CLIENT]);
CREATE NONCLUSTERED INDEX [IX_dbo.ClientPersonal(CP_SURNAME)+(CP_ID_CLIENT)] ON [dbo].[ClientPersonal] ([CP_SURNAME] ASC) INCLUDE ([CP_ID_CLIENT]);
GO
