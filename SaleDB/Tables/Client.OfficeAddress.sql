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
        CONSTRAINT [PK_OfficeAddress] PRIMARY KEY CLUSTERED ([ID]),
        CONSTRAINT [FK_OfficeAddress_Office] FOREIGN KEY  ([ID_OFFICE]) REFERENCES [Client].[Office] ([ID]),
        CONSTRAINT [FK_OfficeAddress_Area] FOREIGN KEY  ([ID_AREA]) REFERENCES [Address].[Area] ([ID]),
        CONSTRAINT [FK_OfficeAddress_Street] FOREIGN KEY  ([ID_STREET]) REFERENCES [Address].[Street] ([ID])
);
GO
CREATE NONCLUSTERED INDEX [IX_AREA] ON [Client].[OfficeAddress] ([ID_AREA] ASC) INCLUDE ([ID_OFFICE]);
CREATE NONCLUSTERED INDEX [IX_HOME] ON [Client].[OfficeAddress] ([HOME] ASC) INCLUDE ([ID_OFFICE]);
CREATE NONCLUSTERED INDEX [IX_ID_ADDRESS] ON [Client].[OfficeAddress] ([ID_OFFICE] ASC) INCLUDE ([ID], [ID_AREA], [ID_STREET], [INDEX], [HOME], [ROOM], [NOTE]);
CREATE NONCLUSTERED INDEX [IX_ROOM] ON [Client].[OfficeAddress] ([ROOM] ASC) INCLUDE ([ID_OFFICE]);
CREATE NONCLUSTERED INDEX [IX_STREET] ON [Client].[OfficeAddress] ([ID_STREET] ASC) INCLUDE ([ID_OFFICE]);
GO
