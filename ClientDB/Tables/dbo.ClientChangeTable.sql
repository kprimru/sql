USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ClientChangeTable]
(
        [ClientChangeID]   bigint        Identity(1,1)   NOT NULL,
        [ClientID]         Int                           NOT NULL,
        [OldValue]         xml                               NULL,
        [NewValue]         xml                               NULL,
        [ChangeUser]       VarChar(50)                   NOT NULL,
        [ChangeHost]       VarChar(50)                   NOT NULL,
        [ChangeDate]       DateTime                      NOT NULL,
        CONSTRAINT [PK_dbo.ClientChangeTable] PRIMARY KEY NONCLUSTERED ([ClientChangeID]),
        CONSTRAINT [FK_dbo.ClientChangeTable(ClientID)_dbo.ClientTable(ClientID)] FOREIGN KEY  ([ClientID]) REFERENCES [dbo].[ClientTable] ([ClientID])
);
GO
CREATE UNIQUE CLUSTERED INDEX [UC_dbo.ClientChangeTable(ClientID,ChangeDate)] ON [dbo].[ClientChangeTable] ([ClientID] ASC, [ChangeDate] ASC);
CREATE NONCLUSTERED INDEX [IX_dbo.ClientChangeTable(ChangeDate)+(ClientID)] ON [dbo].[ClientChangeTable] ([ChangeDate] ASC) INCLUDE ([ClientID]);
GO
