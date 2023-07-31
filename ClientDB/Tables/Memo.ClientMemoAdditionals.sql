USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Memo].[ClientMemoAdditionals]
(
        [Memo_Id]         UniqueIdentifier      NOT NULL,
        [Additional_Id]   UniqueIdentifier      NOT NULL,
        CONSTRAINT [PK_Memo.ClientMemoAdditionals] PRIMARY KEY CLUSTERED ([Memo_Id],[Additional_Id]),
        CONSTRAINT [FK_Memo.ClientMemoAdditionals(Memo_Id)_Memo.ClientMemo(ID)] FOREIGN KEY  ([Memo_Id]) REFERENCES [Memo].[ClientMemo] ([ID]),
        CONSTRAINT [FK_Memo.ClientMemoAdditionals(Additional_Id)_Contract.Additional(ID)] FOREIGN KEY  ([Additional_Id]) REFERENCES [Contract].[Additional] ([ID])
);
GO
