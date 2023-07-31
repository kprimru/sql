USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Memo].[KGSMemoDistr]
(
        [ID]             UniqueIdentifier      NOT NULL,
        [ID_MEMO]        UniqueIdentifier      NOT NULL,
        [ID_CLIENT]      Int                   NOT NULL,
        [ID_SYSTEM]      Int                   NOT NULL,
        [DISTR]          Int                   NOT NULL,
        [COMP]           TinyInt               NOT NULL,
        [ID_NET]         Int                   NOT NULL,
        [ID_TYPE]        Int                   NOT NULL,
        [DISCOUNT]       Int                       NULL,
        [INFLATION]      decimal                   NULL,
        [MON_CNT]        SmallInt              NOT NULL,
        [PRICE]          Money                 NOT NULL,
        [TAX_PRICE]      Money                 NOT NULL,
        [TOTAL_PRICE]    Money                 NOT NULL,
        [CURVED]         TinyInt               NOT NULL,
        [TOTAL_PERIOD]   Money                 NOT NULL,
        CONSTRAINT [PK_Memo.KGSMemoDistr] PRIMARY KEY NONCLUSTERED ([ID]),
        CONSTRAINT [FK_Memo.KGSMemoDistr(ID_MEMO)_Memo.KGSMemo(ID)] FOREIGN KEY  ([ID_MEMO]) REFERENCES [Memo].[KGSMemo] ([ID]),
        CONSTRAINT [FK_Memo.KGSMemoDistr(ID_CLIENT)_dbo.ClientTable(ClientID)] FOREIGN KEY  ([ID_CLIENT]) REFERENCES [dbo].[ClientTable] ([ClientID]),
        CONSTRAINT [FK_Memo.KGSMemoDistr(ID_SYSTEM)_dbo.SystemTable(SystemID)] FOREIGN KEY  ([ID_SYSTEM]) REFERENCES [dbo].[SystemTable] ([SystemID]),
        CONSTRAINT [FK_Memo.KGSMemoDistr(ID_NET)_dbo.DistrTypeTable(DistrTypeID)] FOREIGN KEY  ([ID_NET]) REFERENCES [dbo].[DistrTypeTable] ([DistrTypeID]),
        CONSTRAINT [FK_Memo.KGSMemoDistr(ID_TYPE)_dbo.SystemTypeTable(SystemTypeID)] FOREIGN KEY  ([ID_TYPE]) REFERENCES [dbo].[SystemTypeTable] ([SystemTypeID])
);
GO
CREATE CLUSTERED INDEX [IC_Memo.KGSMemoDistr(ID_MEMO,ID)] ON [Memo].[KGSMemoDistr] ([ID_MEMO] ASC, [ID] ASC);
CREATE NONCLUSTERED INDEX [IX_Memo.KGSMemoDistr(ID_MEMO,DISTR,COMP)] ON [Memo].[KGSMemoDistr] ([ID_MEMO] ASC, [DISTR] ASC, [COMP] ASC);
CREATE NONCLUSTERED INDEX [IX_Memo.KGSMemoDistr(ID_MEMO,ID_SYSTEM,ID_NET,CURVED)+(TOTAL_PRICE)] ON [Memo].[KGSMemoDistr] ([ID_MEMO] ASC, [ID_SYSTEM] ASC, [ID_NET] ASC, [CURVED] ASC) INCLUDE ([TOTAL_PRICE]);
GO
