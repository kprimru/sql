USE [DBF]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ConsignmentDetailTable]
(
        [CSD_ID]               Int            Identity(1,1)   NOT NULL,
        [CSD_ID_CONS]          Int                            NOT NULL,
        [CSD_ID_DISTR]         Int                                NULL,
        [CSD_ID_PERIOD]        SmallInt                           NULL,
        [CSD_NUM]              Int                                NULL,
        [CSD_COST]             Money                              NULL,
        [CSD_PRICE]            Money                          NOT NULL,
        [CSD_TAX_PRICE]        Money                              NULL,
        [CSD_TOTAL_PRICE]      Money                              NULL,
        [CSD_PAYED_PRICE]      Money                              NULL,
        [CSD_CODE]             VarChar(50)                        NULL,
        [CSD_PRICE_NUM]        VarChar(50)                        NULL,
        [CSD_COUNT]            SmallInt                           NULL,
        [CSD_NAME]             VarChar(250)                       NULL,
        [CSD_UNIT]             VarChar(50)                        NULL,
        [CSD_OKEI]             VarChar(20)                        NULL,
        [CSD_PACKING]          VarChar(50)                        NULL,
        [CSD_COUNT_IN_PLACE]   VarChar(50)                        NULL,
        [CSD_PLACE]            VarChar(50)                        NULL,
        [CSD_MASS]             VarChar(50)                        NULL,
        [CSD_NO]               VarChar(50)                        NULL,
        [CSD_ID_TAX]           SmallInt                           NULL,
        [CSD]                  Bit                                NULL,
        CONSTRAINT [PK_dbo.ConsignmentDetailTable] PRIMARY KEY NONCLUSTERED ([CSD_ID]),
        CONSTRAINT [FK_dbo.ConsignmentDetailTable(CSD_ID_CONS)_dbo.ConsignmentTable(CSG_ID)] FOREIGN KEY  ([CSD_ID_CONS]) REFERENCES [dbo].[ConsignmentTable] ([CSG_ID]),
        CONSTRAINT [FK_dbo.ConsignmentDetailTable(CSD_ID_PERIOD)_dbo.PeriodTable(PR_ID)] FOREIGN KEY  ([CSD_ID_PERIOD]) REFERENCES [dbo].[PeriodTable] ([PR_ID]),
        CONSTRAINT [FK_dbo.ConsignmentDetailTable(CSD_ID_TAX)_dbo.TaxTable(TX_ID)] FOREIGN KEY  ([CSD_ID_TAX]) REFERENCES [dbo].[TaxTable] ([TX_ID]),
        CONSTRAINT [FK_dbo.ConsignmentDetailTable(CSD_ID_DISTR)_dbo.DistrTable(DIS_ID)] FOREIGN KEY  ([CSD_ID_DISTR]) REFERENCES [dbo].[DistrTable] ([DIS_ID])
);
GO
CREATE CLUSTERED INDEX [IC_dbo.ConsignmentDetailTable(CSD_ID_CONS,CSD_ID)] ON [dbo].[ConsignmentDetailTable] ([CSD_ID_CONS] ASC, [CSD_ID] ASC);
CREATE NONCLUSTERED INDEX [IX_dbo.ConsignmentDetailTable(CSD_ID,CSD_ID_CONS)+(CSD_TOTAL_PRICE)] ON [dbo].[ConsignmentDetailTable] ([CSD_ID] ASC, [CSD_ID_CONS] ASC) INCLUDE ([CSD_TOTAL_PRICE]);
CREATE NONCLUSTERED INDEX [IX_dbo.ConsignmentDetailTable(CSD_ID,CSD_ID_CONS,CSD_ID_PERIOD,CSD_PRICE)] ON [dbo].[ConsignmentDetailTable] ([CSD_ID] ASC, [CSD_ID_CONS] ASC, [CSD_ID_PERIOD] ASC, [CSD_PRICE] ASC);
CREATE NONCLUSTERED INDEX [IX_dbo.ConsignmentDetailTable(CSD_ID_DISTR,CSD_ID_PERIOD)+(CSD_TOTAL_PRICE)] ON [dbo].[ConsignmentDetailTable] ([CSD_ID_DISTR] ASC, [CSD_ID_PERIOD] ASC) INCLUDE ([CSD_TOTAL_PRICE]);
GO
