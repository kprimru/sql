USE [BuhDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[AddServicePriceTable]
(
        [AddServiceChildID]      Int            Identity(1,1)   NOT NULL,
        [AddServiceID]           Int                            NOT NULL,
        [AddServiceChildName]    VarChar(150)                   NOT NULL,
        [AddServicePrice]        Money                          NOT NULL,
        [AddServiceChildOrder]   Int                            NOT NULL,
        [SaleObjectID]           Int                            NOT NULL,,
        CONSTRAINT [FK_dbo.AddServicePriceTable(SaleObjectID)_dbo.SaleObjectTable(SaleObjectID)] FOREIGN KEY  ([SaleObjectID]) REFERENCES [dbo].[SaleObjectTable] ([SaleObjectID]),
        CONSTRAINT [FK_dbo.AddServicePriceTable(AddServiceID)_dbo.AddServiceTable(AddServiceID)] FOREIGN KEY  ([AddServiceID]) REFERENCES [dbo].[AddServiceTable] ([AddServiceID])
);
GO
GRANT DELETE ON [dbo].[AddServicePriceTable] TO DBAdministrator;
GRANT INSERT ON [dbo].[AddServicePriceTable] TO DBAdministrator;
GRANT SELECT ON [dbo].[AddServicePriceTable] TO DBAdministrator;
GRANT UPDATE ON [dbo].[AddServicePriceTable] TO DBAdministrator;
GRANT SELECT ON [dbo].[AddServicePriceTable] TO DBCount;
GRANT DELETE ON [dbo].[AddServicePriceTable] TO DBPrice;
GRANT INSERT ON [dbo].[AddServicePriceTable] TO DBPrice;
GRANT SELECT ON [dbo].[AddServicePriceTable] TO DBPrice;
GRANT UPDATE ON [dbo].[AddServicePriceTable] TO DBPrice;
GRANT SELECT ON [dbo].[AddServicePriceTable] TO DBPriceReader;
GO
