USE [BuhDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[TaxSaleObjectTable]
(
        [SaleObjectID]   Int      NOT NULL,
        [TaxID]          Int      NOT NULL,,
        CONSTRAINT [FK_dbo.TaxSaleObjectTable(SaleObjectID)_dbo.SaleObjectTable(SaleObjectID)] FOREIGN KEY  ([SaleObjectID]) REFERENCES [dbo].[SaleObjectTable] ([SaleObjectID]),
        CONSTRAINT [FK_dbo.TaxSaleObjectTable(TaxID)_dbo.TaxTable(TaxID)] FOREIGN KEY  ([TaxID]) REFERENCES [dbo].[TaxTable] ([TaxID])
);
GO
CREATE UNIQUE NONCLUSTERED INDEX [UX_dbo.TaxSaleObjectTable(SaleObjectID,TaxID)] ON [dbo].[TaxSaleObjectTable] ([SaleObjectID] ASC, [TaxID] ASC);
GO
GRANT DELETE ON [dbo].[TaxSaleObjectTable] TO DBAdministrator;
GRANT INSERT ON [dbo].[TaxSaleObjectTable] TO DBAdministrator;
GRANT SELECT ON [dbo].[TaxSaleObjectTable] TO DBAdministrator;
GRANT UPDATE ON [dbo].[TaxSaleObjectTable] TO DBAdministrator;
GRANT DELETE ON [dbo].[TaxSaleObjectTable] TO DBCount;
GRANT INSERT ON [dbo].[TaxSaleObjectTable] TO DBCount;
GRANT SELECT ON [dbo].[TaxSaleObjectTable] TO DBCount;
GRANT UPDATE ON [dbo].[TaxSaleObjectTable] TO DBCount;
GRANT SELECT ON [dbo].[TaxSaleObjectTable] TO DBPrice;
GRANT SELECT ON [dbo].[TaxSaleObjectTable] TO DBPriceReader;
GO
