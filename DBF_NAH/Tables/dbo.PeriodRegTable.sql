USE [DBF_NAH]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[PeriodRegTable]
(
        [REG_ID]             bigint          Identity(1,1)   NOT NULL,
        [REG_ID_PERIOD]      SmallInt                        NOT NULL,
        [REG_ID_SYSTEM]      SmallInt                        NOT NULL,
        [REG_DISTR_NUM]      Int                             NOT NULL,
        [REG_COMP_NUM]       TinyInt                         NOT NULL,
        [REG_ID_HOST]        SmallInt                        NOT NULL,
        [REG_ID_TYPE]        SmallInt                        NOT NULL,
        [REG_ID_NET]         SmallInt                        NOT NULL,
        [REG_ID_STATUS]      SmallInt                        NOT NULL,
        [REG_ID_TECH_TYPE]   SmallInt                            NULL,
        [REG_DATE]           SmallDateTime                       NULL,
        [REG_FIRST]          SmallDateTime                       NULL,
        [REG_COMMENT]        VarChar(250)                        NULL,
        [REG_NUM_CLIENT]     Int                                 NULL,
        [REG_PSEDO_CLIENT]   VarChar(100)                        NULL,
        [REG_ID_COUR]        SmallInt                            NULL,
        [REG_COMPLECT]       VarChar(50)                         NULL,
        [REG_MAIN]           TinyInt                             NULL,
        [REG_OFFLINE]        VarChar(50)                         NULL,
        CONSTRAINT [PK_dbo.PeriodRegTable] PRIMARY KEY NONCLUSTERED ([REG_ID]),
        CONSTRAINT [FK_dbo.PeriodRegTable(REG_ID_HOST)_dbo.SubhostTable(SH_ID)] FOREIGN KEY  ([REG_ID_HOST]) REFERENCES [dbo].[SubhostTable] ([SH_ID]),
        CONSTRAINT [FK_dbo.PeriodRegTable(REG_ID_SYSTEM)_dbo.SystemTable(SYS_ID)] FOREIGN KEY  ([REG_ID_SYSTEM]) REFERENCES [dbo].[SystemTable] ([SYS_ID]),
        CONSTRAINT [FK_dbo.PeriodRegTable(REG_ID_STATUS)_dbo.DistrStatusTable(DS_ID)] FOREIGN KEY  ([REG_ID_STATUS]) REFERENCES [dbo].[DistrStatusTable] ([DS_ID]),
        CONSTRAINT [FK_dbo.PeriodRegTable(REG_ID_NET)_dbo.SystemNetCountTable(SNC_ID)] FOREIGN KEY  ([REG_ID_NET]) REFERENCES [dbo].[SystemNetCountTable] ([SNC_ID]),
        CONSTRAINT [FK_dbo.PeriodRegTable(REG_ID_PERIOD)_dbo.PeriodTable(PR_ID)] FOREIGN KEY  ([REG_ID_PERIOD]) REFERENCES [dbo].[PeriodTable] ([PR_ID])
);
GO
CREATE UNIQUE CLUSTERED INDEX [UC_dbo.PeriodRegTable(REG_ID_PERIOD,REG_ID)] ON [dbo].[PeriodRegTable] ([REG_ID_PERIOD] ASC, [REG_ID] ASC);
CREATE NONCLUSTERED INDEX [IX_dbo.PeriodRegTable(REG_ID_PERIOD,REG_COMPLECT)+INCL] ON [dbo].[PeriodRegTable] ([REG_ID_PERIOD] ASC, [REG_COMPLECT] ASC) INCLUDE ([REG_ID_SYSTEM], [REG_DISTR_NUM], [REG_COMP_NUM], [REG_ID_TYPE], [REG_ID_STATUS]);
CREATE NONCLUSTERED INDEX [IX_dbo.PeriodRegTable(REG_ID_PERIOD,REG_DISTR_NUM,REG_COMP_NUM,REG_ID_HOST)+INCL] ON [dbo].[PeriodRegTable] ([REG_ID_PERIOD] ASC, [REG_DISTR_NUM] ASC, [REG_COMP_NUM] ASC, [REG_ID_HOST] ASC) INCLUDE ([REG_ID_SYSTEM], [REG_ID_STATUS]);
CREATE NONCLUSTERED INDEX [IX_dbo.PeriodRegTable(REG_ID_PERIOD,REG_ID_HOST)+INCL] ON [dbo].[PeriodRegTable] ([REG_ID_PERIOD] ASC, [REG_ID_HOST] ASC) INCLUDE ([REG_ID], [REG_ID_SYSTEM], [REG_DISTR_NUM], [REG_COMP_NUM], [REG_ID_TYPE], [REG_ID_NET], [REG_ID_STATUS], [REG_ID_TECH_TYPE], [REG_COMMENT]);
CREATE NONCLUSTERED INDEX [IX_dbo.PeriodRegTable(REG_ID_PERIOD,REG_ID_STATUS)+INCL] ON [dbo].[PeriodRegTable] ([REG_ID_PERIOD] ASC, [REG_ID_STATUS] ASC) INCLUDE ([REG_ID], [REG_ID_SYSTEM], [REG_ID_HOST], [REG_ID_TYPE], [REG_ID_NET], [REG_ID_TECH_TYPE], [REG_DISTR_NUM], [REG_COMP_NUM]);
CREATE NONCLUSTERED INDEX [IX_dbo.PeriodRegTable(REG_ID_PERIOD,REG_NUM_CLIENT)+INCL] ON [dbo].[PeriodRegTable] ([REG_ID_PERIOD] ASC, [REG_NUM_CLIENT] ASC) INCLUDE ([REG_ID_SYSTEM], [REG_DISTR_NUM], [REG_COMP_NUM], [REG_ID_STATUS]);
CREATE NONCLUSTERED INDEX [IX_dbo.PeriodRegTable(REG_ID_SYSTEM,REG_DISTR_NUM,REG_COMP_NUM)+INCL] ON [dbo].[PeriodRegTable] ([REG_ID_SYSTEM] ASC, [REG_DISTR_NUM] ASC, [REG_COMP_NUM] ASC) INCLUDE ([REG_ID_PERIOD], [REG_MAIN], [REG_COMPLECT], [REG_ID_STATUS]);
CREATE NONCLUSTERED INDEX [IX_PeriodRegTable_REG_ID_PERIOD_REG_ID_HOST1] ON [dbo].[PeriodRegTable] ([REG_ID_PERIOD] ASC, [REG_ID_HOST] ASC) INCLUDE ([REG_ID_SYSTEM], [REG_DISTR_NUM], [REG_COMP_NUM], [REG_ID_TYPE], [REG_ID_NET], [REG_ID_STATUS], [REG_COMPLECT]);
GO
GRANT SELECT ON [dbo].[PeriodRegTable] TO rl_reg_node_report_r;
GO
