USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[OriContractTable]
(
        [OriContractID]       Int             Identity(1,1)   NOT NULL,
        [ClientID]            Int                             NOT NULL,
        [OriContractDate]     SmallDateTime                   NOT NULL,
        [OriContractSystem]   VarChar(Max)                    NOT NULL,
        [OriContractNote]     VarChar(Max)                    NOT NULL,
        CONSTRAINT [PK_dbo.OriContractTable] PRIMARY KEY NONCLUSTERED ([OriContractID]),
        CONSTRAINT [FK_dbo.OriContractTable(ClientID)_dbo.ClientTable(ClientID)] FOREIGN KEY  ([ClientID]) REFERENCES [dbo].[ClientTable] ([ClientID])
);
GO
CREATE UNIQUE CLUSTERED INDEX [UC_dbo.OriContractTable(ClientID,OriContractID)] ON [dbo].[OriContractTable] ([ClientID] ASC, [OriContractID] ASC);
GO
