USE [DBF]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Ric].[HostAbonement]
(
        [HA_ID]          Int        Identity(1,1)   NOT NULL,
        [HA_ID_PERIOD]   SmallInt                   NOT NULL,
        [HA_ID_HOST]     SmallInt                   NOT NULL,
        [HA_PRICE]       Money                      NOT NULL,
        CONSTRAINT [PK_Ric.HostAbonement] PRIMARY KEY CLUSTERED ([HA_ID]),
        CONSTRAINT [FK_Ric.HostAbonement(HA_ID_PERIOD)_Ric.PeriodTable(PR_ID)] FOREIGN KEY  ([HA_ID_PERIOD]) REFERENCES [dbo].[PeriodTable] ([PR_ID]),
        CONSTRAINT [FK_Ric.HostAbonement(HA_ID_HOST)_Ric.HostTable(HST_ID)] FOREIGN KEY  ([HA_ID_HOST]) REFERENCES [dbo].[HostTable] ([HST_ID])
);
GO
