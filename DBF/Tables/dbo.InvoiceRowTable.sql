USE [DBF]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[InvoiceRowTable]
(
        [INR_ID]           Int            Identity(1,1)   NOT NULL,
        [INR_ID_INVOICE]   Int                            NOT NULL,
        [INR_ID_DISTR]     Int                                NULL,
        [INR_ID_PERIOD]    SmallInt                           NULL,
        [INR_GOOD]         VarChar(150)                       NULL,
        [INR_NAME]         VarChar(500)                       NULL,
        [INR_SUM]          Money                              NULL,
        [INR_ID_TAX]       SmallInt                           NULL,
        [INR_TNDS]         decimal                            NULL,
        [INR_SNDS]         Money                              NULL,
        [INR_SALL]         Money                              NULL,
        [INR_PPRICE]       Money                              NULL,
        [INR_UNIT]         VarChar(100)                       NULL,
        [INR_COUNT]        SmallInt                           NULL,
        CONSTRAINT [PK_dbo.InvoiceRowTable] PRIMARY KEY NONCLUSTERED ([INR_ID]),
        CONSTRAINT [FK_dbo.InvoiceRowTable(INR_ID_INVOICE)_dbo.InvoiceSaleTable(INS_ID)] FOREIGN KEY  ([INR_ID_INVOICE]) REFERENCES [dbo].[InvoiceSaleTable] ([INS_ID]),
        CONSTRAINT [FK_dbo.InvoiceRowTable(INR_ID_PERIOD)_dbo.PeriodTable(PR_ID)] FOREIGN KEY  ([INR_ID_PERIOD]) REFERENCES [dbo].[PeriodTable] ([PR_ID]),
        CONSTRAINT [FK_dbo.InvoiceRowTable(INR_ID_TAX)_dbo.TaxTable(TX_ID)] FOREIGN KEY  ([INR_ID_TAX]) REFERENCES [dbo].[TaxTable] ([TX_ID]),
        CONSTRAINT [FK_dbo.InvoiceRowTable(INR_ID_DISTR)_dbo.DistrTable(DIS_ID)] FOREIGN KEY  ([INR_ID_DISTR]) REFERENCES [dbo].[DistrTable] ([DIS_ID])
);
GO
CREATE CLUSTERED INDEX [IC_dbo.InvoiceRowTable(INR_ID_INVOICE)] ON [dbo].[InvoiceRowTable] ([INR_ID_INVOICE] ASC);
CREATE NONCLUSTERED INDEX [IX_dbo.InvoiceRowTable(INR_ID_DISTR)] ON [dbo].[InvoiceRowTable] ([INR_ID_DISTR] ASC);
CREATE NONCLUSTERED INDEX [IX_dbo.InvoiceRowTable(INR_ID_INVOICE)+INCL] ON [dbo].[InvoiceRowTable] ([INR_ID_INVOICE] ASC) INCLUDE ([INR_ID_DISTR], [INR_ID_PERIOD], [INR_SUM], [INR_TNDS], [INR_SNDS], [INR_SALL], [INR_COUNT]);
GO
