USE [FirstInstall]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Salary].[BonusConditionDetail]
(
        [BC_ID]               UniqueIdentifier      NOT NULL,
        [BC_ID_MASTER]        UniqueIdentifier      NOT NULL,
        [BC_PREPAY]           Bit                       NULL,
        [BC_MON_COUNT]        TinyInt                   NULL,
        [BC_ACTION]           Bit                       NULL,
        [BC_EXCHANGE]         Bit                       NULL,
        [BC_DT_SUP_CON]       Bit                       NULL,
        [BC_RESTORE_MAIN]     Bit                       NULL,
        [BC_RESTORE_ADD]      Bit                       NULL,
        [BC_SUP_PRICE]        Bit                   NOT NULL,
        [BC_RES_PRICE]        Bit                   NOT NULL,
        [BC_PERCENT]          decimal               NOT NULL,
        [BC_SECOND_PERCENT]   decimal                   NULL,
        [BC_ORDER]            Int                   NOT NULL,
        [BC_DATE]             SmallDateTime         NOT NULL,
        [BC_END]              SmallDateTime             NULL,
        [BC_REF]              TinyInt               NOT NULL,
        CONSTRAINT [PK_Salary.BonusConditionDetail] PRIMARY KEY CLUSTERED ([BC_ID]),
        CONSTRAINT [FK_Salary.BonusConditionDetail(BC_ID_MASTER)_Salary.BonusCondition(BCMS_ID)] FOREIGN KEY  ([BC_ID_MASTER]) REFERENCES [Salary].[BonusCondition] ([BCMS_ID])
);GO
