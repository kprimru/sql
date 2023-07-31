USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Contract].[ClientContractsFoundations]
(
        [Contract_Id]     UniqueIdentifier      NOT NULL,
        [DATE]            SmallDateTime         NOT NULL,
        [Foundation_Id]   UniqueIdentifier      NOT NULL,
        [ExpireDate]      SmallDateTime             NULL,
        [Note]            VarChar(Max)              NULL,
        CONSTRAINT [PK_Contract.ClientContractsFoundations] PRIMARY KEY CLUSTERED ([Contract_Id],[DATE]),
        CONSTRAINT [FK_Contract.ClientContractsFoundations(Contract_Id)_Contract.Contract(ID)] FOREIGN KEY  ([Contract_Id]) REFERENCES [Contract].[Contract] ([ID]),
        CONSTRAINT [FK_Contract.ClientContractsFoundations(Foundation_Id)_dbo.ContractFoundation(ID)] FOREIGN KEY  ([Foundation_Id]) REFERENCES [dbo].[ContractFoundation] ([ID])
);
GO
