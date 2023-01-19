USE [BuhDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[AddServiceTable]
(
        [AddServiceID]      Int            Identity(1,1)   NOT NULL,
        [AddServiceName]    VarChar(150)                   NOT NULL,
        [AddServicePrice]   Money                          NOT NULL,
        [AddServiceOrder]   Int                            NOT NULL,
        [SaleObjectID]      Int                            NOT NULL,
        [PrintService]      Int                            NOT NULL,
        CONSTRAINT [PK_dbo.AddServiceTable] PRIMARY KEY CLUSTERED ([AddServiceID]),
        CONSTRAINT [FK_dbo.AddServiceTable(SaleObjectID)_dbo.SaleObjectTable(SaleObjectID)] FOREIGN KEY  ([SaleObjectID]) REFERENCES [dbo].[SaleObjectTable] ([SaleObjectID])
);
GO
GRANT DELETE ON [dbo].[AddServiceTable] TO DBAdministrator;
GRANT INSERT ON [dbo].[AddServiceTable] TO DBAdministrator;
GRANT SELECT ON [dbo].[AddServiceTable] TO DBAdministrator;
GRANT UPDATE ON [dbo].[AddServiceTable] TO DBAdministrator;
GRANT SELECT ON [dbo].[AddServiceTable] TO DBCount;
GRANT DELETE ON [dbo].[AddServiceTable] TO DBPrice;
GRANT INSERT ON [dbo].[AddServiceTable] TO DBPrice;
GRANT SELECT ON [dbo].[AddServiceTable] TO DBPrice;
GRANT UPDATE ON [dbo].[AddServiceTable] TO DBPrice;
GRANT SELECT ON [dbo].[AddServiceTable] TO DBPriceReader;
GO
