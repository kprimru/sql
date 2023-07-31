USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Memo].[ClientMemoSpecifications]
(
        [Memo_Id]            UniqueIdentifier      NOT NULL,
        [Specification_Id]   UniqueIdentifier      NOT NULL,
        CONSTRAINT [PK_Memo.ClientMemoSpecifications] PRIMARY KEY CLUSTERED ([Memo_Id],[Specification_Id]),
        CONSTRAINT [FK_Memo.ClientMemoSpecifications(Memo_Id)_Memo.ClientMemo(ID)] FOREIGN KEY  ([Memo_Id]) REFERENCES [Memo].[ClientMemo] ([ID]),
        CONSTRAINT [FK_Memo.ClientMemoSpecifications(Specification_Id)_Contract.ContractSpecification(ID)] FOREIGN KEY  ([Specification_Id]) REFERENCES [Contract].[ContractSpecification] ([ID])
);
GO
