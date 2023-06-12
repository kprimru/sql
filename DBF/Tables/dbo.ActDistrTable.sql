USE [DBF]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ActDistrTable]
(
        [AD_ID]            Int             Identity(1,1)   NOT NULL,
        [AD_ID_ACT]        Int                             NOT NULL,
        [AD_ID_DISTR]      Int                             NOT NULL,
        [AD_ID_PERIOD]     SmallInt                        NOT NULL,
        [AD_PRICE]         Money                           NOT NULL,
        [AD_ID_TAX]        SmallInt                        NOT NULL,
        [AD_TAX_PRICE]     Money                           NOT NULL,
        [AD_TOTAL_PRICE]   Money                           NOT NULL,
        [AD_PAYED_PRICE]   Money                           NOT NULL,
        [ACT]              Bit                                 NULL,
        [AD_ID_COUR]       SmallInt                            NULL,
        [AD_EXPIRE]        SmallDateTime                       NULL,
        [IsOnline]         Bit                                 NULL,
        CONSTRAINT [PK_dbo.ActDistrTable] PRIMARY KEY NONCLUSTERED ([AD_ID]),
        CONSTRAINT [FK_dbo.ActDistrTable(AD_ID_COUR)_dbo.CourierTable(COUR_ID)] FOREIGN KEY  ([AD_ID_COUR]) REFERENCES [dbo].[CourierTable] ([COUR_ID]),
        CONSTRAINT [FK_dbo.ActDistrTable(AD_ID_PERIOD)_dbo.PeriodTable(PR_ID)] FOREIGN KEY  ([AD_ID_PERIOD]) REFERENCES [dbo].[PeriodTable] ([PR_ID]),
        CONSTRAINT [FK_dbo.ActDistrTable(AD_ID_ACT)_dbo.ActTable(ACT_ID)] FOREIGN KEY  ([AD_ID_ACT]) REFERENCES [dbo].[ActTable] ([ACT_ID]),
        CONSTRAINT [FK_dbo.ActDistrTable(AD_ID_TAX)_dbo.TaxTable(TX_ID)] FOREIGN KEY  ([AD_ID_TAX]) REFERENCES [dbo].[TaxTable] ([TX_ID]),
        CONSTRAINT [FK_dbo.ActDistrTable(AD_ID_DISTR)_dbo.DistrTable(DIS_ID)] FOREIGN KEY  ([AD_ID_DISTR]) REFERENCES [dbo].[DistrTable] ([DIS_ID])
);
GO
CREATE CLUSTERED INDEX [IC_dbo.ActDistrTable(AD_ID_ACT,AD_ID_DISTR,AD_ID_PERIOD)] ON [dbo].[ActDistrTable] ([AD_ID_ACT] ASC, [AD_ID_DISTR] ASC, [AD_ID_PERIOD] ASC);
CREATE NONCLUSTERED INDEX [IX_dbo.ActDistrTable(AD_ID)+(AD_ID_ACT,AD_ID_DISTR,AD_ID_PERIOD,AD_TOTAL_PRICE,AD_PRICE)] ON [dbo].[ActDistrTable] ([AD_ID] ASC) INCLUDE ([AD_ID_ACT], [AD_ID_DISTR], [AD_ID_PERIOD], [AD_TOTAL_PRICE], [AD_PRICE]);
CREATE NONCLUSTERED INDEX [IX_dbo.ActDistrTable(AD_ID_DISTR,AD_ID_PERIOD)+(AD_ID_TAX)] ON [dbo].[ActDistrTable] ([AD_ID_DISTR] ASC, [AD_ID_PERIOD] ASC) INCLUDE ([AD_ID_TAX]);
GO
