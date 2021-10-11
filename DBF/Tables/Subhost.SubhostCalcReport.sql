USE [DBF]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Subhost].[SubhostCalcReport]
(
        [SCR_ID]             Int        Identity(1,1)   NOT NULL,
        [SCR_ID_SUBHOST]     SmallInt                   NOT NULL,
        [SCR_ID_PERIOD]      SmallInt                   NOT NULL,
        [SCR_DELIVERY_SYS]   Money                      NOT NULL,
        [SCR_SUPPORT]        Money                      NOT NULL,
        [SCR_CNT]            SmallInt                   NOT NULL,
        [SCR_CNT_SPEC]       SmallInt                   NOT NULL,
        [SCR_DIU]            Money                      NOT NULL,
        [SCR_PAPPER]         Money                      NOT NULL,
        [SCR_MARKET]         Money                      NOT NULL,
        [SCR_STUDY]          Money                      NOT NULL,
        [SCR_NDS10]          Money                      NOT NULL,
        [SCR_IC]             Money                      NOT NULL,
        [SCR_IC_NDS]         Money                      NOT NULL,
        [SCR_IC_DEBT]        Money                      NOT NULL,
        [SCR_IC_PENALTY]     Money                      NOT NULL,
        [SCR_DELIVERY]       Money                      NOT NULL,
        [SCR_TRAFFIC]        Money                      NOT NULL,
        [SCR_TOTAL_18]       Money                      NOT NULL,
        [SCR_NDS_18]         Money                      NOT NULL,
        [SCR_TOTAL_NDS]      Money                      NOT NULL,
        [SCR_INCOME]         Money                      NOT NULL,
        [SCR_DEBT]           Money                      NOT NULL,
        [SCR_SALDO]          Money                      NOT NULL,
        [SCR_PENALTY]        Money                      NOT NULL,
        [SCR_TOTAL]          Money                      NOT NULL,
        CONSTRAINT [PK_Subhost.SubhostCalcReport] PRIMARY KEY CLUSTERED ([SCR_ID]),
        CONSTRAINT [FK_Subhost.SubhostCalcReport(SCR_ID_SUBHOST)_Subhost.SubhostTable(SH_ID)] FOREIGN KEY  ([SCR_ID_SUBHOST]) REFERENCES [dbo].[SubhostTable] ([SH_ID]),
        CONSTRAINT [FK_Subhost.SubhostCalcReport(SCR_ID_PERIOD)_Subhost.PeriodTable(PR_ID)] FOREIGN KEY  ([SCR_ID_PERIOD]) REFERENCES [dbo].[PeriodTable] ([PR_ID])
);GO
