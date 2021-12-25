USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Contract].[ClientContractsDetails]
(
        [Contract_Id]     UniqueIdentifier      NOT NULL,
        [DATE]            SmallDateTime         NOT NULL,
        [ExpireDate]      SmallDateTime             NULL,
        [Type_Id]         Int                   NOT NULL,
        [PayType_Id]      Int                       NULL,
        [Discount_Id]     Int                       NULL,
        [ContractPrice]   Money                     NULL,
        [Comments]        VarChar(Max)              NULL,
        CONSTRAINT [PK_Contract.ClientContractsDetails] PRIMARY KEY CLUSTERED ([Contract_Id],[DATE]),
        CONSTRAINT [FK_Contract.ClientContractsDetails(Contract_Id)_Contract.Contract(ID)] FOREIGN KEY  ([Contract_Id]) REFERENCES [Contract].[Contract] ([ID]),
        CONSTRAINT [FK_Contract.ClientContractsDetails(Type_Id)_Contract.ContractTypeTable(ContractTypeID)] FOREIGN KEY  ([Type_Id]) REFERENCES [dbo].[ContractTypeTable] ([ContractTypeID]),
        CONSTRAINT [FK_Contract.ClientContractsDetails(PayType_Id)_Contract.ContractPayTable(ContractPayID)] FOREIGN KEY  ([PayType_Id]) REFERENCES [dbo].[ContractPayTable] ([ContractPayID]),
        CONSTRAINT [FK_Contract.ClientContractsDetails(Discount_Id)_Contract.DiscountTable(DiscountID)] FOREIGN KEY  ([Discount_Id]) REFERENCES [dbo].[DiscountTable] ([DiscountID])
);
GO
