USE [FirstInstall]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Income].[IncomePersonal]
(
        [IP_ID]            UniqueIdentifier      NOT NULL,
        [IP_ID_INCOME]     UniqueIdentifier      NOT NULL,
        [IP_ID_PERSONAL]   UniqueIdentifier      NOT NULL,
        [IP_PERCENT]       decimal               NOT NULL,
        [IP_ID_MONTH]      UniqueIdentifier          NULL,
        [IP_PERCENT2]      decimal                   NULL,
        CONSTRAINT [PK_Income.IncomePersonal] PRIMARY KEY CLUSTERED ([IP_ID]),
        CONSTRAINT [FK_Income.IncomePersonal(IP_ID_PERSONAL)_Income.Personals(PERMS_ID)] FOREIGN KEY  ([IP_ID_PERSONAL]) REFERENCES [Personal].[Personals] ([PERMS_ID]),
        CONSTRAINT [FK_Income.IncomePersonal(IP_ID_INCOME)_Income.IncomeDetail(ID_ID)] FOREIGN KEY  ([IP_ID_INCOME]) REFERENCES [Income].[IncomeDetail] ([ID_ID]),
        CONSTRAINT [FK_Income.IncomePersonal(IP_ID_MONTH)_Income.Period(PRMS_ID)] FOREIGN KEY  ([IP_ID_MONTH]) REFERENCES [Common].[Period] ([PRMS_ID])
);
GO
CREATE NONCLUSTERED INDEX [IX_Income.IncomePersonal(IP_ID_INCOME,IP_ID_PERSONAL)+(IP_PERCENT,IP_PERCENT2)] ON [Income].[IncomePersonal] ([IP_ID_INCOME] ASC, [IP_ID_PERSONAL] ASC) INCLUDE ([IP_PERCENT], [IP_PERCENT2]);
CREATE UNIQUE NONCLUSTERED INDEX [UX_Income.IncomePersonal(IP_ID_INCOME,IP_ID_PERSONAL)] ON [Income].[IncomePersonal] ([IP_ID_INCOME] ASC, [IP_ID_PERSONAL] ASC);
GO
