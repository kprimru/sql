USE [DBF_NAH]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[IncomeDistrTable]
(
        [ID_ID]          Int             Identity(1,1)   NOT NULL,
        [ID_ID_INCOME]   Int                             NOT NULL,
        [ID_ID_DISTR]    Int                             NOT NULL,
        [ID_PRICE]       Money                           NOT NULL,
        [ID_DATE]        SmallDateTime                   NOT NULL,
        [ID_ID_PERIOD]   SmallInt                            NULL,
        [ID_PREPAY]      Bit                             NOT NULL,
        [ID_ACTION]      Bit                                 NULL,
        CONSTRAINT [PK_dbo.IncomeDistrTable] PRIMARY KEY NONCLUSTERED ([ID_ID]),
        CONSTRAINT [FK_dbo.IncomeDistrTable(ID_ID_INCOME)_dbo.IncomeTable(IN_ID)] FOREIGN KEY  ([ID_ID_INCOME]) REFERENCES [dbo].[IncomeTable] ([IN_ID]),
        CONSTRAINT [FK_dbo.IncomeDistrTable(ID_ID_PERIOD)_dbo.PeriodTable(PR_ID)] FOREIGN KEY  ([ID_ID_PERIOD]) REFERENCES [dbo].[PeriodTable] ([PR_ID]),
        CONSTRAINT [FK_dbo.IncomeDistrTable(ID_ID_DISTR)_dbo.DistrTable(DIS_ID)] FOREIGN KEY  ([ID_ID_DISTR]) REFERENCES [dbo].[DistrTable] ([DIS_ID])
);
GO
CREATE CLUSTERED INDEX [IC_dbo.IncomeDistrTable(ID_ID_INCOME,ID_ID_DISTR,ID_ID_PERIOD)] ON [dbo].[IncomeDistrTable] ([ID_ID_INCOME] ASC, [ID_ID_DISTR] ASC, [ID_ID_PERIOD] ASC);
CREATE NONCLUSTERED INDEX [IX_dbo.IncomeDistrTable(ID_ID,ID_ID_INCOME)+(ID_ID_DISTR,ID_PRICE,ID_ID_PERIOD)] ON [dbo].[IncomeDistrTable] ([ID_ID] ASC, [ID_ID_INCOME] ASC) INCLUDE ([ID_ID_DISTR], [ID_PRICE], [ID_ID_PERIOD]);
CREATE NONCLUSTERED INDEX [IX_dbo.IncomeDistrTable(ID_ID_DISTR,ID_ID_PERIOD)+(ID_PRICE)] ON [dbo].[IncomeDistrTable] ([ID_ID_DISTR] ASC, [ID_ID_PERIOD] ASC) INCLUDE ([ID_PRICE]);
CREATE NONCLUSTERED INDEX [IX_dbo.IncomeDistrTable(ID_ID_PERIOD)+(ID_ID_DISTR,ID_PRICE)] ON [dbo].[IncomeDistrTable] ([ID_ID_PERIOD] ASC) INCLUDE ([ID_ID_DISTR], [ID_PRICE]);
GO
