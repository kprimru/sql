USE [DBF_NAH]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[PeriodRegNewTable]
(
        [RNN_ID]             Int             Identity(1,1)   NOT NULL,
        [RNN_ID_PERIOD]      SmallInt                        NOT NULL,
        [RNN_ID_SYSTEM]      SmallInt                        NOT NULL,
        [RNN_DISTR_NUM]      Int                             NOT NULL,
        [RNN_COMP_NUM]       TinyInt                         NOT NULL,
        [RNN_ID_HOST]        SmallInt                        NOT NULL,
        [RNN_ID_TYPE]        SmallInt                        NOT NULL,
        [RNN_DATE]           SmallDateTime                       NULL,
        [RNN_DATE_ON]        SmallDateTime                       NULL,
        [RNN_ID_NET]         SmallInt                        NOT NULL,
        [RNN_ID_TECH_TYPE]   SmallInt                            NULL,
        [RNN_NUM_CLIENT]     Int                                 NULL,
        [RNN_PSEDO_CLIENT]   VarChar(100)                        NULL,
        [RNN_COMMENT]        VarChar(250)                        NULL,
        CONSTRAINT [PK_dbo.PeriodRegNewTable] PRIMARY KEY NONCLUSTERED ([RNN_ID]),
        CONSTRAINT [FK_dbo.PeriodRegNewTable(RNN_ID_HOST)_dbo.SubhostTable(SH_ID)] FOREIGN KEY  ([RNN_ID_HOST]) REFERENCES [dbo].[SubhostTable] ([SH_ID]),
        CONSTRAINT [FK_dbo.PeriodRegNewTable(RNN_ID_NET)_dbo.SystemNetCountTable(SNC_ID)] FOREIGN KEY  ([RNN_ID_NET]) REFERENCES [dbo].[SystemNetCountTable] ([SNC_ID])
);
GO
CREATE CLUSTERED INDEX [IC_dbo.PeriodRegNewTable+COL+INCL] ON [dbo].[PeriodRegNewTable] ([RNN_ID_PERIOD] ASC, [RNN_ID_SYSTEM] ASC, [RNN_ID_HOST] ASC, [RNN_ID_TYPE] ASC, [RNN_ID_NET] ASC, [RNN_ID_TECH_TYPE] ASC, [RNN_ID] ASC);
CREATE NONCLUSTERED INDEX [IX_dbo.PeriodRegNewTable(RNN_DATE)+(RNN_ID_PERIOD,RNN_ID_SYSTEM)] ON [dbo].[PeriodRegNewTable] ([RNN_DATE] ASC) INCLUDE ([RNN_ID_PERIOD], [RNN_ID_SYSTEM]);
CREATE NONCLUSTERED INDEX [IX_dbo.PeriodRegNewTable(RNN_DISTR_NUM,RNN_ID_SYSTEM,RNN_COMP_NUM,RNN_DATE)] ON [dbo].[PeriodRegNewTable] ([RNN_DISTR_NUM] ASC, [RNN_ID_SYSTEM] ASC, [RNN_COMP_NUM] ASC, [RNN_DATE] ASC);
GO
GRANT SELECT ON [dbo].[PeriodRegNewTable] TO rl_reg_node_report_r;
GO
