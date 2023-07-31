USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Memo].[ClientMemo]
(
        [ID]                     UniqueIdentifier      NOT NULL,
        [ID_CLIENT]              Int                   NOT NULL,
        [DATE]                   DateTime              NOT NULL,
        [CURRENT_CONTRACT]       NVarChar(1024)        NOT NULL,
        [DISTR]                  NVarChar(Max)         NOT NULL,
        [ID_DOC_TYPE]            UniqueIdentifier      NOT NULL,
        [ID_SERVICE]             UniqueIdentifier      NOT NULL,
        [ID_VENDOR]              UniqueIdentifier      NOT NULL,
        [START]                  SmallDateTime             NULL,
        [FINISH]                 SmallDateTime             NULL,
        [MONTH_PRICE]            Money                 NOT NULL,
        [PERIOD_PRICE]           Money                     NULL,
        [PERIOD_START]           SmallDateTime             NULL,
        [PERIOD_END]             SmallDateTime             NULL,
        [PERIOD_FULL_PRICE]      Money                     NULL,
        [ID_CONTRACT_PAY_TYPE]   Int                       NULL,
        [ID_PAY_TYPE]            Int                       NULL,
        [FRAMEWORK]              NVarChar(2048)        NOT NULL,
        [DOCUMENTS]              NVarChar(2048)        NOT NULL,
        [LETTER_CANCEL]          Bit                   NOT NULL,
        [SYSTEMS]                NVarChar(Max)             NULL,
        [Contract_Id]            UniqueIdentifier          NULL,
        CONSTRAINT [PK_Memo.ClientMemo] PRIMARY KEY CLUSTERED ([ID]),
        CONSTRAINT [FK_Memo.ClientMemo(ID_CLIENT)_dbo.ClientTable(ClientID)] FOREIGN KEY  ([ID_CLIENT]) REFERENCES [dbo].[ClientTable] ([ClientID]),
        CONSTRAINT [FK_Memo.ClientMemo(Contract_Id)_Contract.Contract(ID)] FOREIGN KEY  ([Contract_Id]) REFERENCES [Contract].[Contract] ([ID]),
        CONSTRAINT [FK_Memo.ClientMemo(ID_DOC_TYPE)_Memo.Document(ID)] FOREIGN KEY  ([ID_DOC_TYPE]) REFERENCES [Memo].[Document] ([ID]),
        CONSTRAINT [FK_Memo.ClientMemo(ID_SERVICE)_Memo.Service(ID)] FOREIGN KEY  ([ID_SERVICE]) REFERENCES [Memo].[Service] ([ID]),
        CONSTRAINT [FK_Memo.ClientMemo(ID_VENDOR)_dbo.Vendor(ID)] FOREIGN KEY  ([ID_VENDOR]) REFERENCES [dbo].[Vendor] ([ID]),
        CONSTRAINT [FK_Memo.ClientMemo(ID_CONTRACT_PAY_TYPE)_dbo.ContractPayTable(ContractPayID)] FOREIGN KEY  ([ID_CONTRACT_PAY_TYPE]) REFERENCES [dbo].[ContractPayTable] ([ContractPayID])
);
GO
CREATE NONCLUSTERED INDEX [IX_Memo.ClientMemo(ID_CLIENT)] ON [Memo].[ClientMemo] ([ID_CLIENT] ASC);
GO
