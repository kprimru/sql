USE [SaleDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Client].[OfficeAddress]
(
        [ID]          UniqueIdentifier      NOT NULL,
        [ID_OFFICE]   UniqueIdentifier      NOT NULL,
        [ID_AREA]     UniqueIdentifier          NULL,
        [ID_STREET]   UniqueIdentifier          NULL,
        [INDEX]       NVarChar(64)              NULL,
        [HOME]        NVarChar(128)             NULL,
        [ROOM]        NVarChar(128)             NULL,
        [NOTE]        NVarChar(Max)             NULL,
        CONSTRAINT [PK_Client.OfficeAddress] PRIMARY KEY CLUSTERED ([ID]),
        CONSTRAINT [FK_Client.OfficeAddress(ID_OFFICE)_Client.Office(ID)] FOREIGN KEY  ([ID_OFFICE]) REFERENCES [Client].[Office] ([ID]),
        CONSTRAINT [FK_Client.OfficeAddress(ID_AREA)_Client.Area(ID)] FOREIGN KEY  ([ID_AREA]) REFERENCES [Address].[Area] ([ID]),
        CONSTRAINT [FK_Client.OfficeAddress(ID_STREET)_Client.Street(ID)] FOREIGN KEY  ([ID_STREET]) REFERENCES [Address].[Street] ([ID])
);
GO
CREATE NONCLUSTERED INDEX [IX_Client.OfficeAddress(HOME)+(ID_OFFICE)] ON [Client].[OfficeAddress] ([HOME] ASC) INCLUDE ([ID_OFFICE]);
CREATE NONCLUSTERED INDEX [IX_Client.OfficeAddress(ID_AREA)+(ID_OFFICE)] ON [Client].[OfficeAddress] ([ID_AREA] ASC) INCLUDE ([ID_OFFICE]);
CREATE NONCLUSTERED INDEX [IX_Client.OfficeAddress(ID_OFFICE)+(ID,ID_AREA,ID_STREET,INDEX,HOME,ROOM,NOTE)] ON [Client].[OfficeAddress] ([ID_OFFICE] ASC) INCLUDE ([ID], [ID_AREA], [ID_STREET], [INDEX], [HOME], [ROOM], [NOTE]);
CREATE NONCLUSTERED INDEX [IX_Client.OfficeAddress(ID_STREET)+(ID_OFFICE)] ON [Client].[OfficeAddress] ([ID_STREET] ASC) INCLUDE ([ID_OFFICE]);
CREATE NONCLUSTERED INDEX [IX_Client.OfficeAddress(ROOM)+(ID_OFFICE)] ON [Client].[OfficeAddress] ([ROOM] ASC) INCLUDE ([ID_OFFICE]);
GO
