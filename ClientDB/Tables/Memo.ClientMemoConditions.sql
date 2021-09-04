USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Memo].[ClientMemoConditions]
(
        [ID]          UniqueIdentifier      NOT NULL,
        [ID_MEMO]     UniqueIdentifier      NOT NULL,
        [CONDITION]   NVarChar(Max)         NOT NULL,
        [ORD]         Int                   NOT NULL,
        CONSTRAINT [PK_Memo.ClientMemoConditions] PRIMARY KEY CLUSTERED ([ID]),
        CONSTRAINT [FK_Memo.ClientMemoConditions(ID_MEMO)_Memo.ClientMemo(ID)] FOREIGN KEY  ([ID_MEMO]) REFERENCES [Memo].[ClientMemo] ([ID])
);
GO
CREATE NONCLUSTERED INDEX [IX_Memo.ClientMemoConditions(ID_MEMO)] ON [Memo].[ClientMemoConditions] ([ID_MEMO] ASC);
GO
