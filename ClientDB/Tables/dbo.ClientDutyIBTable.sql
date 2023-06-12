USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ClientDutyIBTable]
(
        [ClientDutyIB]   Int   Identity(1,1)   NOT NULL,
        [ClientDutyID]   Int                   NOT NULL,
        [SystemID]       Int                   NOT NULL,
        CONSTRAINT [PK_dbo.ClientDutyIBTable] PRIMARY KEY NONCLUSTERED ([ClientDutyIB]),
        CONSTRAINT [FK_dbo.ClientDutyIBTable(SystemID)_dbo.SystemTable(SystemID)] FOREIGN KEY  ([SystemID]) REFERENCES [dbo].[SystemTable] ([SystemID]),
        CONSTRAINT [FK_dbo.ClientDutyIBTable(ClientDutyID)_dbo.ClientDutyTable(ClientDutyID)] FOREIGN KEY  ([ClientDutyID]) REFERENCES [dbo].[ClientDutyTable] ([ClientDutyID])
);
GO
CREATE UNIQUE CLUSTERED INDEX [UC_dbo.ClientDutyIBTable(ClientDutyID,SystemID)] ON [dbo].[ClientDutyIBTable] ([ClientDutyID] ASC, [SystemID] ASC);
GO
