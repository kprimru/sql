USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[OriPersonTable]
(
        [OriPersonID]      Int            Identity(1,1)   NOT NULL,
        [ClientID]         Int                            NOT NULL,
        [OriPersonName]    VarChar(250)                   NOT NULL,
        [OriPersonPhone]   VarChar(250)                   NOT NULL,
        [OriPersonPlace]   VarChar(100)                   NOT NULL,
        CONSTRAINT [PK_dbo.OriPersonTable] PRIMARY KEY NONCLUSTERED ([OriPersonID]),
        CONSTRAINT [FK_dbo.OriPersonTable(ClientID)_dbo.ClientTable(ClientID)] FOREIGN KEY  ([ClientID]) REFERENCES [dbo].[ClientTable] ([ClientID])
);
GO
CREATE UNIQUE CLUSTERED INDEX [UC_dbo.OriPersonTable(ClientID,OriPersonID)] ON [dbo].[OriPersonTable] ([ClientID] ASC, [OriPersonID] ASC);
GO
