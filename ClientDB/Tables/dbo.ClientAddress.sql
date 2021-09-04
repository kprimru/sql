USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ClientAddress]
(
        [CA_ID]            UniqueIdentifier      NOT NULL,
        [CA_ID_CLIENT]     Int                   NOT NULL,
        [CA_ID_TYPE]       UniqueIdentifier      NOT NULL,
        [CA_NAME]          VarChar(150)              NULL,
        [CA_INDEX]         VarChar(20)               NULL,
        [CA_ID_STREET]     UniqueIdentifier          NULL,
        [CA_HOME]          VarChar(50)               NULL,
        [CA_OFFICE]        VarChar(100)              NULL,
        [CA_HINT]          VarChar(Max)              NULL,
        [CA_NOTE]          VarChar(Max)              NULL,
        [CA_ID_DISTRICT]   UniqueIdentifier          NULL,
        [CA_MAP]           varbinary                 NULL,
        CONSTRAINT [PK_dbo.ClientAddress] PRIMARY KEY NONCLUSTERED ([CA_ID]),
        CONSTRAINT [FK_dbo.ClientAddress(CA_ID_TYPE)_dbo.AddressType(AT_ID)] FOREIGN KEY  ([CA_ID_TYPE]) REFERENCES [dbo].[AddressType] ([AT_ID]),
        CONSTRAINT [FK_dbo.ClientAddress(CA_ID_DISTRICT)_dbo.District(DS_ID)] FOREIGN KEY  ([CA_ID_DISTRICT]) REFERENCES [dbo].[District] ([DS_ID]),
        CONSTRAINT [FK_dbo.ClientAddress(CA_ID_CLIENT)_dbo.ClientTable(ClientID)] FOREIGN KEY  ([CA_ID_CLIENT]) REFERENCES [dbo].[ClientTable] ([ClientID]),
        CONSTRAINT [FK_dbo.ClientAddress(CA_ID_STREET)_dbo.Street(ST_ID)] FOREIGN KEY  ([CA_ID_STREET]) REFERENCES [dbo].[Street] ([ST_ID])
);
GO
CREATE UNIQUE CLUSTERED INDEX [UC_dbo.ClientAddress(CA_ID_CLIENT,CA_ID)] ON [dbo].[ClientAddress] ([CA_ID_CLIENT] ASC, [CA_ID] ASC);
CREATE NONCLUSTERED INDEX [IX_dbo.ClientAddress(CA_ID_TYPE)+(CA_ID_STREET,CA_HOME,CA_OFFICE)] ON [dbo].[ClientAddress] ([CA_ID_TYPE] ASC) INCLUDE ([CA_ID_STREET], [CA_HOME], [CA_OFFICE]);
GO
