USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[StatisticTable]
(
        [StatisticID]     bigint          Identity(1,1)   NOT NULL,
        [StatisticDate]   SmallDateTime                   NOT NULL,
        [InfoBankID]      SmallInt                        NOT NULL,
        [Docs]            Int                             NOT NULL,
        [UpdateDate]      DateTime                        NOT NULL,
        CONSTRAINT [PK_dbo.StatisticTable] PRIMARY KEY NONCLUSTERED ([StatisticID]),
        CONSTRAINT [FK_dbo.StatisticTable(InfoBankID)_dbo.InfoBankTable(InfoBankID)] FOREIGN KEY  ([InfoBankID]) REFERENCES [dbo].[InfoBankTable] ([InfoBankID])
);
GO
CREATE UNIQUE CLUSTERED INDEX [UC_dbo.StatisticTable(StatisticDate,InfoBankID)] ON [dbo].[StatisticTable] ([StatisticDate] ASC, [InfoBankID] ASC);
CREATE NONCLUSTERED INDEX [IX_dbo.StatisticTable(InfoBankID,Docs)+(StatisticID,StatisticDate)] ON [dbo].[StatisticTable] ([InfoBankID] ASC, [Docs] ASC) INCLUDE ([StatisticID], [StatisticDate]);
CREATE NONCLUSTERED INDEX [IX_dbo.StatisticTable(InfoBankID,StatisticDate)] ON [dbo].[StatisticTable] ([InfoBankID] ASC, [StatisticDate] ASC);
GO
GRANT SELECT ON [dbo].[StatisticTable] TO DBStatistic;
GO
