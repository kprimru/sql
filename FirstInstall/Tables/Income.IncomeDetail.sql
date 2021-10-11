USE [FirstInstall]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Income].[IncomeDetail]
(
        [ID_ID]             UniqueIdentifier      NOT NULL,
        [ID_ID_INCOME]      UniqueIdentifier      NOT NULL,
        [ID_ID_SYSTEM]      UniqueIdentifier      NOT NULL,
        [ID_ID_TYPE]        UniqueIdentifier      NOT NULL,
        [ID_ID_NET]         UniqueIdentifier      NOT NULL,
        [ID_ID_TECH]        UniqueIdentifier      NOT NULL,
        [ID_COUNT]          TinyInt               NOT NULL,
        [ID_SALARY]         Money                     NULL,
        [ID_DEL_SUM]        Money                     NULL,
        [ID_DEL_PRICE]      Money                 NOT NULL,
        [ID_DEL_DISCOUNT]   decimal                   NULL,
        [ID_ACTION]         Bit                   NOT NULL,
        [ID_RESTORE]        Bit                   NOT NULL,
        [ID_EXCHANGE]       Bit                   NOT NULL,
        [ID_ID_FULL_PAY]    UniqueIdentifier          NULL,
        [ID_FULL_DATE]      SmallDateTime             NULL,
        [ID_ID_FIRST_MON]   UniqueIdentifier          NULL,
        [ID_MON_CNT]        TinyInt                   NULL,
        [ID_MON_STR]         AS ([Income].[IncomeMonthString]([ID_ID])) ,
        [ID_SUP_PRICE]      Money                     NULL,
        [ID_SUP_DISCOUNT]   decimal                   NULL,
        [ID_SUP_MONTH]      Money                     NULL,
        [ID_PREPAY]         Bit                       NULL,
        [ID_SUP_CONTRACT]   SmallDateTime             NULL,
        [ID_SUP_DATE]       SmallDateTime             NULL,
        [ID_COMMENT]         AS (isnull(reverse(stuff(reverse((case [ID_ACTION] when (1) then 'Акция,' else '' end+case [ID_EXCHANGE] when (1) then 'Замена,' else '' end)+case [ID_RESTORE] when (1) then 'Восст.,' else '' end),(1),(1),'')),'')) PERSISTED,
        [ID_REPAY]          Bit                   NOT NULL,
        [ID_LOCK]           Bit                   NOT NULL,
        [ID_NOTE]           VarChar(250)              NULL,
        [ID_CALC]           Bit                       NULL,
        [ID_MAIN]           Bit                       NULL,
        [ID_COLOR]          Int                       NULL,
        [ID_INSTALL]        Bit                       NULL,
        [ID_ORANGE]         Bit                   NOT NULL,
        CONSTRAINT [PK_IncomeDetail] PRIMARY KEY CLUSTERED ([ID_ID]),
        CONSTRAINT [FK_IncomeDetail_Period] FOREIGN KEY  ([ID_ID_FIRST_MON]) REFERENCES [Common].[Period] ([PRMS_ID]),
        CONSTRAINT [FK_IncomeDetail_DistrType] FOREIGN KEY  ([ID_ID_TYPE]) REFERENCES [Distr].[DistrType] ([DTMS_ID]),
        CONSTRAINT [FK_IncomeDetail_NetType] FOREIGN KEY  ([ID_ID_NET]) REFERENCES [Distr].[NetType] ([NTMS_ID]),
        CONSTRAINT [FK_IncomeDetail_Systems] FOREIGN KEY  ([ID_ID_SYSTEM]) REFERENCES [Distr].[Systems] ([SYSMS_ID]),
        CONSTRAINT [FK_IncomeDetail_TechType] FOREIGN KEY  ([ID_ID_TECH]) REFERENCES [Distr].[TechType] ([TTMS_ID]),
        CONSTRAINT [FK_IncomeDetail_Period1] FOREIGN KEY  ([ID_ID_FIRST_MON]) REFERENCES [Common].[Period] ([PRMS_ID]),
        CONSTRAINT [FK_IncomeDetail_Period2] FOREIGN KEY  ([ID_ID_FULL_PAY]) REFERENCES [Common].[Period] ([PRMS_ID]),
        CONSTRAINT [FK_IncomeDetail_Incomes] FOREIGN KEY  ([ID_ID_INCOME]) REFERENCES [Income].[Incomes] ([IN_ID])
);
GO
CREATE NONCLUSTERED INDEX [IX_INC] ON [Income].[IncomeDetail] ([ID_ID_SYSTEM] ASC, [ID_ID_TYPE] ASC, [ID_ID_NET] ASC, [ID_ID_TECH] ASC) INCLUDE ([ID_ID_INCOME]);
CREATE NONCLUSTERED INDEX [IX_IncomeDetail_ID_FULL_DATE] ON [Income].[IncomeDetail] ([ID_FULL_DATE] ASC);
CREATE NONCLUSTERED INDEX [IX_IncomeDetail_ID_ID_INCOME_ID_ID_SYSTEM_ID_ID_TYPE_ID_ID_NET_ID_ID_TECH] ON [Income].[IncomeDetail] ([ID_ID_INCOME] ASC, [ID_ID_SYSTEM] ASC, [ID_ID_TYPE] ASC, [ID_ID_NET] ASC, [ID_ID_TECH] ASC) INCLUDE ([ID_ID]);
CREATE NONCLUSTERED INDEX [IX_IncomeDetail_ID_ID_SYSTEM_ID_ID_TYPE_ID_ID_NET_ID_ID_TECH] ON [Income].[IncomeDetail] ([ID_ID_SYSTEM] ASC, [ID_ID_TYPE] ASC, [ID_ID_NET] ASC, [ID_ID_TECH] ASC) INCLUDE ([ID_ID_INCOME], [ID_DEL_SUM], [ID_ID_FULL_PAY], [ID_ID_FIRST_MON]);
CREATE NONCLUSTERED INDEX [IX_IncomeDetail_ID_LOCK] ON [Income].[IncomeDetail] ([ID_LOCK] ASC) INCLUDE ([ID_ID], [ID_FULL_DATE]);
CREATE NONCLUSTERED INDEX [IX_IncomeDetail_ID_RESTORE_ID_LOCK] ON [Income].[IncomeDetail] ([ID_RESTORE] ASC, [ID_LOCK] ASC) INCLUDE ([ID_ID], [ID_FULL_DATE]);
GO
