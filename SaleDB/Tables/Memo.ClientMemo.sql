USE [SaleDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Memo].[ClientMemo]
(
        [ID]                  UniqueIdentifier      NOT NULL,
        [ID_CLIENT]           UniqueIdentifier          NULL,
        [DATE]                DateTime              NOT NULL,
        [ID_DOC_TYPE]         UniqueIdentifier          NULL,
        [ID_SERVICE]          UniqueIdentifier          NULL,
        [ID_VENDOR]           UniqueIdentifier          NULL,
        [START]               SmallDateTime             NULL,
        [FINISH]              SmallDateTime             NULL,
        [MONTH_PRICE]         Money                     NULL,
        [PERIOD_PRICE]        Money                     NULL,
        [PERIOD_START]        SmallDateTime             NULL,
        [PERIOD_FINISH]       SmallDateTime             NULL,
        [PERIOD_FULL_PRICE]   Money                     NULL,
        [ID_PAY_TYPE]         Int                       NULL,
        [ID_CONTRACT_PAY]     Int                       NULL,
        [FRAMEWORK]           NVarChar(2048)            NULL,
        [DOCUMENTS]           NVarChar(2048)            NULL,
        [LETTER_CANCEL]       Bit                       NULL,
        [SYSTEMS]             NVarChar(Max)             NULL,
        CONSTRAINT [PK_Memo.ClientMemo] PRIMARY KEY CLUSTERED ([ID])
);
GO
