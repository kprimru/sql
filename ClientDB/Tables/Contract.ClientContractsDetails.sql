USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Contract].[ClientContractsDetails]
(
        [Contract_Id]           UniqueIdentifier      NOT NULL,
        [DATE]                  SmallDateTime         NOT NULL,
        [ExpireDate]            SmallDateTime             NULL,
        [Type_Id]               Int                   NOT NULL,
        [PayType_Id]            Int                       NULL,
        [Discount_Id]           Int                       NULL,
        [ContractPrice]         Money                     NULL,
        [Comments]              VarChar(Max)              NULL,
        [DocumentFlowType_Id]   TinyInt                   NULL,
        [ActSignPeriod_Id]      SmallInt                  NULL,
        CONSTRAINT [PK_Contract.ClientContractsDetails] PRIMARY KEY CLUSTERED ([Contract_Id],[DATE]),
        CONSTRAINT [FK_Contract.ClientContractsDetails(Contract_Id)_Contract.Contract(ID)] FOREIGN KEY  ([Contract_Id]) REFERENCES [Contract].[Contract] ([ID]),
        CONSTRAINT [FK_Contract.ClientContractsDetails(Type_Id)_dbo.ContractTypeTable(ContractTypeID)] FOREIGN KEY  ([Type_Id]) REFERENCES [dbo].[ContractTypeTable] ([ContractTypeID]),
        CONSTRAINT [FK_Contract.ClientContractsDetails(PayType_Id)_dbo.ContractPayTable(ContractPayID)] FOREIGN KEY  ([PayType_Id]) REFERENCES [dbo].[ContractPayTable] ([ContractPayID]),
        CONSTRAINT [FK_Contract.ClientContractsDetails(Discount_Id)_dbo.DiscountTable(DiscountID)] FOREIGN KEY  ([Discount_Id]) REFERENCES [dbo].[DiscountTable] ([DiscountID]),
        CONSTRAINT [FK_Contract.ClientContractsDetails(ActSignPeriod_Id)_Contract.Contracts->Act Sign Periods(Id)] FOREIGN KEY  ([ActSignPeriod_Id]) REFERENCES [Contract].[Contracts->Act Sign Periods] ([Id]),
        CONSTRAINT [FK_Contract.ClientContractsDetails(DocumentFlowType_Id)_Contract.Contracts->Documents Flow Types(Id)] FOREIGN KEY  ([DocumentFlowType_Id]) REFERENCES [Contract].[Contracts->Documents Flow Types] ([Id])
);
GO
