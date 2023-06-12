USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Contract].[ClientContracts]
(
        [Client_Id]     Int                   NOT NULL,
        [Contract_Id]   UniqueIdentifier      NOT NULL,
        CONSTRAINT [PK_Contract.ClientContracts] PRIMARY KEY CLUSTERED ([Client_Id],[Contract_Id]),
        CONSTRAINT [FK_Contract.ClientContracts(Contract_Id)_Contract.Contract(ID)] FOREIGN KEY  ([Contract_Id]) REFERENCES [Contract].[Contract] ([ID]),
        CONSTRAINT [FK_Contract.ClientContracts(Client_Id)_Contract.ClientTable(ClientID)] FOREIGN KEY  ([Client_Id]) REFERENCES [dbo].[ClientTable] ([ClientID])
);
GO
CREATE UNIQUE NONCLUSTERED INDEX [UX_Contract.ClientContracts(Contract_Id,Client_Id)] ON [Contract].[ClientContracts] ([Contract_Id] ASC, [Client_Id] ASC);
GO
