USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[EventTable]
(
        [EventID]               Int             Identity(1,1)   NOT NULL,
        [MasterID]              Int                                 NULL,
        [ClientID]              Int                             NOT NULL,
        [EventDate]             SmallDateTime                       NULL,
        [EventComment]          VarChar(Max)                        NULL,
        [EventTypeID]           Int                             NOT NULL,
        [EventCreate]           DateTime                            NULL,
        [EventLastUpdate]       DateTime                            NULL,
        [EventCreateUser]       NVarChar(256)                       NULL,
        [EventLastUpdateUser]   NVarChar(256)                       NULL,
        [EventActive]           Bit                                 NULL,
        CONSTRAINT [PK_dbo.EventTable] PRIMARY KEY NONCLUSTERED ([EventID]),
        CONSTRAINT [FK_dbo.EventTable(ClientID)_dbo.ClientTable(ClientID)] FOREIGN KEY  ([ClientID]) REFERENCES [dbo].[ClientTable] ([ClientID]),
        CONSTRAINT [FK_dbo.EventTable(EventTypeID)_dbo.EventTypeTable(EventTypeID)] FOREIGN KEY  ([EventTypeID]) REFERENCES [dbo].[EventTypeTable] ([EventTypeID])
);
GO
CREATE UNIQUE CLUSTERED INDEX [UC_dbo.EventTable(ClientID,EventID)] ON [dbo].[EventTable] ([ClientID] ASC, [EventID] ASC);
CREATE NONCLUSTERED INDEX [IX_dbo.EventTable(ClientID,EventActive,EventDate,EventID,EventCreateUser,EventTypeID)+(EventComment)] ON [dbo].[EventTable] ([ClientID] ASC, [EventActive] ASC, [EventDate] ASC, [EventID] ASC, [EventCreateUser] ASC, [EventTypeID] ASC) INCLUDE ([EventComment]);
CREATE NONCLUSTERED INDEX [IX_dbo.EventTable(EventCreateUser)+(EventID,MasterID)] ON [dbo].[EventTable] ([EventCreateUser] ASC) INCLUDE ([EventID], [MasterID]);
CREATE NONCLUSTERED INDEX [IX_dbo.EventTable(EventDate)+INCL] ON [dbo].[EventTable] ([EventDate] ASC) INCLUDE ([EventID], [MasterID], [ClientID], [EventComment], [EventTypeID], [EventCreate], [EventLastUpdate], [EventCreateUser], [EventLastUpdateUser], [EventActive]);
CREATE NONCLUSTERED INDEX [IX_dbo.EventTable(MasterID)] ON [dbo].[EventTable] ([MasterID] ASC);
GO
