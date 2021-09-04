USE [DBF_NAH]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[BillDistrTable]
(
        [BD_ID]            Int             Identity(1,1)   NOT NULL,
        [BD_ID_BILL]       Int                             NOT NULL,
        [BD_ID_DISTR]      Int                             NOT NULL,
        [BD_ID_TAX]        SmallInt                        NOT NULL,
        [BD_PRICE]         Money                           NOT NULL,
        [BD_TAX_PRICE]     Money                           NOT NULL,
        [BD_TOTAL_PRICE]   Money                           NOT NULL,
        [BD_DATE]          SmallDateTime                       NULL,
        CONSTRAINT [PK_dbo.BillDistrTable] PRIMARY KEY NONCLUSTERED ([BD_ID]),
        CONSTRAINT [FK_dbo.BillDistrTable(BD_ID_TAX)_dbo.TaxTable(TX_ID)] FOREIGN KEY  ([BD_ID_TAX]) REFERENCES [dbo].[TaxTable] ([TX_ID]),
        CONSTRAINT [FK_dbo.BillDistrTable(BD_ID_DISTR)_dbo.DistrTable(DIS_ID)] FOREIGN KEY  ([BD_ID_DISTR]) REFERENCES [dbo].[DistrTable] ([DIS_ID]),
        CONSTRAINT [FK_dbo.BillDistrTable(BD_ID_BILL)_dbo.BillTable(BL_ID)] FOREIGN KEY  ([BD_ID_BILL]) REFERENCES [dbo].[BillTable] ([BL_ID])
);
GO
CREATE UNIQUE CLUSTERED INDEX [UC_dbo.BillDistrTable(BD_ID_BILL,BD_ID_DISTR)] ON [dbo].[BillDistrTable] ([BD_ID_BILL] ASC, [BD_ID_DISTR] ASC);
CREATE NONCLUSTERED INDEX [IX_dbo.BillDistrTable(BD_ID_DISTR)+(BD_ID_BILL,BD_TOTAL_PRICE)] ON [dbo].[BillDistrTable] ([BD_ID_DISTR] ASC) INCLUDE ([BD_ID_BILL], [BD_TOTAL_PRICE]);
GO
