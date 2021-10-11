USE [DBF]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Ric].[HostPeriod]
(
        [HP_ID]            Int        Identity(1,1)   NOT NULL,
        [HP_ID_HOST]       SmallInt                   NOT NULL,
        [HP_ID_PERIOD]     SmallInt                       NULL,
        [HP_ID_INC_PREF]   SmallInt                       NULL,
        CONSTRAINT [PK_Ric.HostPeriod] PRIMARY KEY CLUSTERED ([HP_ID]),
        CONSTRAINT [FK_Ric.HostPeriod(HP_ID_HOST)_Ric.HostTable(HST_ID)] FOREIGN KEY  ([HP_ID_HOST]) REFERENCES [dbo].[HostTable] ([HST_ID]),
        CONSTRAINT [FK_Ric.HostPeriod(HP_ID_PERIOD)_Ric.PeriodTable(PR_ID)] FOREIGN KEY  ([HP_ID_PERIOD]) REFERENCES [dbo].[PeriodTable] ([PR_ID]),
        CONSTRAINT [FK_Ric.HostPeriod(HP_ID_INC_PREF)_Ric.PeriodTable(PR_ID)] FOREIGN KEY  ([HP_ID_INC_PREF]) REFERENCES [dbo].[PeriodTable] ([PR_ID])
);GO
