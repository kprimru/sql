USE [DBF_NAH]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[TOAddressTable]
(
        [TA_ID]          Int            Identity(1,1)   NOT NULL,
        [TA_ID_TO]       Int                            NOT NULL,
        [TA_INDEX]       VarChar(20)                    NOT NULL,
        [TA_ID_STREET]   Int                            NOT NULL,
        [TA_HOME]        VarChar(200)                   NOT NULL,
        CONSTRAINT [PK_dbo.TOAddressTable] PRIMARY KEY NONCLUSTERED ([TA_ID]),
        CONSTRAINT [FK_dbo.TOAddressTable(TA_ID_TO)_dbo.TOTable(TO_ID)] FOREIGN KEY  ([TA_ID_TO]) REFERENCES [dbo].[TOTable] ([TO_ID]),
        CONSTRAINT [FK_dbo.TOAddressTable(TA_ID_STREET)_dbo.StreetTable(ST_ID)] FOREIGN KEY  ([TA_ID_STREET]) REFERENCES [dbo].[StreetTable] ([ST_ID])
);
GO
CREATE CLUSTERED INDEX [IC_dbo.TOAddressTable(TA_ID_TO,TA_ID,TA_ID_STREET,TA_HOME)] ON [dbo].[TOAddressTable] ([TA_ID_TO] DESC, [TA_ID] ASC, [TA_ID_STREET] ASC, [TA_HOME] ASC);
CREATE NONCLUSTERED INDEX [IX_dbo.TOAddressTable(TA_ID_STREET)+(TA_ID,TA_ID_TO,TA_INDEX,TA_HOME)] ON [dbo].[TOAddressTable] ([TA_ID_STREET] ASC) INCLUDE ([TA_ID], [TA_ID_TO], [TA_INDEX], [TA_HOME]);
GO
