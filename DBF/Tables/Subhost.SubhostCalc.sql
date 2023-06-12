USE [DBF]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Subhost].[SubhostCalc]
(
        [SHC_ID]               Int             Identity(1,1)   NOT NULL,
        [SHC_ID_SUBHOST]       SmallInt                        NOT NULL,
        [SHC_ID_PERIOD]        SmallInt                        NOT NULL,
        [SHC_KBU]              decimal                             NULL,
        [SHC_DELIVERY]         Money                               NULL,
        [SHC_PAPPER_COUNT]     Int                                 NULL,
        [SHC_PAPPER_PRICE]     Money                               NULL,
        [SHC_TRAFFIC]          Money                               NULL,
        [SHC_SEMINAR]          Money                               NULL,
        [SHC_STUDY]            Money                               NULL,
        [SHC_MARKET]           Money                               NULL,
        [SHC_DIU]              Money                               NULL,
        [SHC_TOTAL]            Money                               NULL,
        [SHC_TOTAL_STUDY]      Money                               NULL,
        [SHC_INV_DATE]         SmallDateTime                       NULL,
        [SHC_INV_NUM]          VarChar(50)                         NULL,
        [SHC_INV_STUDY_DATE]   SmallDateTime                       NULL,
        [SHC_INV_STUDY_NUM]    VarChar(50)                         NULL,
        [SHC_CLOSED]           Bit                                 NULL,
        CONSTRAINT [PK_Subhost.SubhostCalc] PRIMARY KEY CLUSTERED ([SHC_ID]),
        CONSTRAINT [FK_Subhost.SubhostCalc(SHC_ID_SUBHOST)_Subhost.SubhostTable(SH_ID)] FOREIGN KEY  ([SHC_ID_SUBHOST]) REFERENCES [dbo].[SubhostTable] ([SH_ID]),
        CONSTRAINT [FK_Subhost.SubhostCalc(SHC_ID_PERIOD)_Subhost.PeriodTable(PR_ID)] FOREIGN KEY  ([SHC_ID_PERIOD]) REFERENCES [dbo].[PeriodTable] ([PR_ID])
);
GO
CREATE UNIQUE NONCLUSTERED INDEX [UX_Subhost.SubhostCalc(SHC_ID_SUBHOST,SHC_ID_PERIOD)] ON [Subhost].[SubhostCalc] ([SHC_ID_SUBHOST] ASC, [SHC_ID_PERIOD] ASC);
GO
