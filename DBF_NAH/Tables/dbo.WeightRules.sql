USE [DBF_NAH]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[WeightRules]
(
        [ID]          Int        Identity(1,1)   NOT NULL,
        [ID_PERIOD]   SmallInt                   NOT NULL,
        [ID_SYSTEM]   SmallInt                   NOT NULL,
        [ID_TYPE]     SmallInt                   NOT NULL,
        [ID_NET]      SmallInt                   NOT NULL,
        [WEIGHT]      decimal                        NULL,
        CONSTRAINT [PK_dbo.WeightRules] PRIMARY KEY CLUSTERED ([ID]),
        CONSTRAINT [FK_dbo.WeightRules(ID_PERIOD)_dbo.PeriodTable(PR_ID)] FOREIGN KEY  ([ID_PERIOD]) REFERENCES [dbo].[PeriodTable] ([PR_ID]),
        CONSTRAINT [FK_dbo.WeightRules(ID_NET)_dbo.SystemNetCountTable(SNC_ID)] FOREIGN KEY  ([ID_NET]) REFERENCES [dbo].[SystemNetCountTable] ([SNC_ID]),
        CONSTRAINT [FK_dbo.WeightRules(ID_SYSTEM)_dbo.SystemTable(SYS_ID)] FOREIGN KEY  ([ID_SYSTEM]) REFERENCES [dbo].[SystemTable] ([SYS_ID]),
        CONSTRAINT [FK_dbo.WeightRules(ID_TYPE)_dbo.SystemTypeTable(SST_ID)] FOREIGN KEY  ([ID_TYPE]) REFERENCES [dbo].[SystemTypeTable] ([SST_ID])
);
GO
CREATE UNIQUE NONCLUSTERED INDEX [UX_dbo.WeightRules(ID_PERIOD,ID_SYSTEM,ID_TYPE,ID_NET)+(WEIGHT)] ON [dbo].[WeightRules] ([ID_PERIOD] ASC, [ID_SYSTEM] ASC, [ID_TYPE] ASC, [ID_NET] ASC) INCLUDE ([WEIGHT]);
GO
