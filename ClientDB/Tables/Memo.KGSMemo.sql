USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Memo].[KGSMemo]
(
        [ID]          UniqueIdentifier      NOT NULL,
        [ID_MASTER]   UniqueIdentifier          NULL,
        [NAME]        NVarChar(256)         NOT NULL,
        [DATE]        SmallDateTime         NOT NULL,
        [PRICE]       Money                     NULL,
        [ID_MONTH]    UniqueIdentifier      NOT NULL,
        [MON_CNT]     SmallInt                  NULL,
        [STATUS]      TinyInt               NOT NULL,
        [UPD_DATE]    DateTime              NOT NULL,
        [UPD_USER]    NVarChar(256)         NOT NULL,
        CONSTRAINT [PK_Memo.KGSMemo] PRIMARY KEY CLUSTERED ([ID]),
        CONSTRAINT [FK_Memo.KGSMemo(ID_MONTH)_Memo.Period(ID)] FOREIGN KEY  ([ID_MONTH]) REFERENCES [Common].[Period] ([ID])
);
GO
