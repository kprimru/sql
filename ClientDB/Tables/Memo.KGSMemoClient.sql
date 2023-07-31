USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Memo].[KGSMemoClient]
(
        [ID]          UniqueIdentifier      NOT NULL,
        [ID_MEMO]     UniqueIdentifier      NOT NULL,
        [ID_CLIENT]   Int                   NOT NULL,
        [NAME]        NVarChar(1024)        NOT NULL,
        [ADDRESS]     NVarChar(1024)        NOT NULL,
        [NUM]         SmallInt              NOT NULL,
        CONSTRAINT [PK_Memo.KGSMemoClient] PRIMARY KEY NONCLUSTERED ([ID]),
        CONSTRAINT [FK_Memo.KGSMemoClient(ID_MEMO)_Memo.KGSMemo(ID)] FOREIGN KEY  ([ID_MEMO]) REFERENCES [Memo].[KGSMemo] ([ID]),
        CONSTRAINT [FK_Memo.KGSMemoClient(ID_CLIENT)_dbo.ClientTable(ClientID)] FOREIGN KEY  ([ID_CLIENT]) REFERENCES [dbo].[ClientTable] ([ClientID])
);
GO
CREATE CLUSTERED INDEX [IC_Memo.KGSMemoClient(ID_MEMO,ID)] ON [Memo].[KGSMemoClient] ([ID_MEMO] ASC, [ID] ASC);
GO
