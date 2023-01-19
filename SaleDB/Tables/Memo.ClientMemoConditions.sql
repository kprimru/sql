USE [SaleDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Memo].[ClientMemoConditions]
(
        [ID]          UniqueIdentifier      NOT NULL,
        [ID_MEMO]     UniqueIdentifier          NULL,
        [CONDITION]   NVarChar(Max)         NOT NULL,
        [ORD]         Int                   NOT NULL,
        CONSTRAINT [PK_Memo.ClientMemoConditions] PRIMARY KEY CLUSTERED ([ID])
);
GO
