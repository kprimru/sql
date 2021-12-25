USE [FirstInstall]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Income].[IncomeBook]
(
        [IB_ID]            UniqueIdentifier      NOT NULL,
        [IB_DATE]          SmallDateTime         NOT NULL,
        [IB_ID_MASTER]     UniqueIdentifier          NULL,
        [IB_REPAY]         Bit                   NOT NULL,
        [IB_ID_CLIENT]     UniqueIdentifier      NOT NULL,
        [IB_ID_VENDOR]     UniqueIdentifier      NOT NULL,
        [IB_PRICE]         Money                 NOT NULL,
        [IB_SUM]           Money                 NOT NULL,
        [IB_COUNT]         TinyInt               NOT NULL,
        [IB_FULL_PAY]      SmallDateTime             NULL,
        [IB_ID_HALF]       UniqueIdentifier      NOT NULL,
        [IB_ID_PERSONAL]   UniqueIdentifier          NULL,
        [IB_LOCK]          Bit                   NOT NULL,
        [IB_NOTE]          VarChar(250)              NULL,
        CONSTRAINT [PK_IncomeBook] PRIMARY KEY CLUSTERED ([IB_ID]),
        CONSTRAINT [FK_IncomeBook_Half] FOREIGN KEY  ([IB_ID_HALF]) REFERENCES [Common].[Half] ([HLFMS_ID]),
        CONSTRAINT [FK_IncomeBook_Incomes] FOREIGN KEY  ([IB_ID_MASTER]) REFERENCES [Income].[IncomeBook] ([IB_ID]),
        CONSTRAINT [FK_IncomeBook_Personals] FOREIGN KEY  ([IB_ID_PERSONAL]) REFERENCES [Personal].[Personals] ([PERMS_ID])
);GO
