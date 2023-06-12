USE [DBF]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ClientAddressTable]
(
        [CA_ID]            Int            Identity(1,1)   NOT NULL,
        [CA_ID_CLIENT]     Int                            NOT NULL,
        [CA_ID_TYPE]       TinyInt                        NOT NULL,
        [CA_INDEX]         VarChar(10)                        NULL,
        [CA_ID_STREET]     Int                                NULL,
        [CA_HOME]          VarChar(50)                        NULL,
        [CA_STR]           VarChar(500)                       NULL,
        [CA_ID_TEMPLATE]   SmallInt                           NULL,
        [CA_FREE]          VarChar(500)                       NULL,
        CONSTRAINT [PK_dbo.ClientAddressTable] PRIMARY KEY NONCLUSTERED ([CA_ID]),
        CONSTRAINT [FK_dbo.ClientAddressTable(CA_ID_CLIENT)_dbo.ClientTable(CL_ID)] FOREIGN KEY  ([CA_ID_CLIENT]) REFERENCES [dbo].[ClientTable] ([CL_ID]),
        CONSTRAINT [FK_dbo.ClientAddressTable(CA_ID_STREET)_dbo.StreetTable(ST_ID)] FOREIGN KEY  ([CA_ID_STREET]) REFERENCES [dbo].[StreetTable] ([ST_ID]),
        CONSTRAINT [FK_dbo.ClientAddressTable(CA_ID_TYPE)_dbo.AddressTypeTable(AT_ID)] FOREIGN KEY  ([CA_ID_TYPE]) REFERENCES [dbo].[AddressTypeTable] ([AT_ID]),
        CONSTRAINT [FK_dbo.ClientAddressTable(CA_ID_TEMPLATE)_dbo.AddressTemplateTable(ATL_ID)] FOREIGN KEY  ([CA_ID_TEMPLATE]) REFERENCES [dbo].[AddressTemplateTable] ([ATL_ID])
);
GO
CREATE UNIQUE CLUSTERED INDEX [UC_dbo.ClientAddressTable(CA_ID_CLIENT,CA_ID_TYPE)] ON [dbo].[ClientAddressTable] ([CA_ID_CLIENT] ASC, [CA_ID_TYPE] ASC);
CREATE NONCLUSTERED INDEX [IX_dbo.ClientAddressTable(CA_ID_STREET)] ON [dbo].[ClientAddressTable] ([CA_ID_STREET] ASC);
CREATE NONCLUSTERED INDEX [IX_dbo.ClientAddressTable(CA_ID_STREET,CA_HOME)+(CA_ID_CLIENT)] ON [dbo].[ClientAddressTable] ([CA_ID_STREET] ASC, [CA_HOME] ASC) INCLUDE ([CA_ID_CLIENT]);
CREATE NONCLUSTERED INDEX [IX_dbo.ClientAddressTable(CA_ID_TYPE)+(CA_ID)] ON [dbo].[ClientAddressTable] ([CA_ID_TYPE] ASC) INCLUDE ([CA_ID]);
GO
GRANT SELECT ON [dbo].[ClientAddressTable] TO rl_all_r;
GRANT SELECT ON [dbo].[ClientAddressTable] TO rl_client_fin_r;
GRANT SELECT ON [dbo].[ClientAddressTable] TO rl_client_r;
GRANT SELECT ON [dbo].[ClientAddressTable] TO rl_fin_r;
GRANT SELECT ON [dbo].[ClientAddressTable] TO rl_to_r;
GO
