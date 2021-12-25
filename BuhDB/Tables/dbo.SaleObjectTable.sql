USE [BuhDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[SaleObjectTable]
(
        [SaleObjectID]     Int            Identity(1,1)   NOT NULL,
        [SaleObjectName]   VarChar(150)                   NOT NULL,
        CONSTRAINT [PK_dbo.SaleObjectTable] PRIMARY KEY CLUSTERED ([SaleObjectID])
);
GO
CREATE UNIQUE NONCLUSTERED INDEX [UX_dbo.SaleObjectTable(SaleObjectName)] ON [dbo].[SaleObjectTable] ([SaleObjectName] ASC);
GO
GRANT DELETE ON [dbo].[SaleObjectTable] TO DBAdministrator;
GRANT INSERT ON [dbo].[SaleObjectTable] TO DBAdministrator;
GRANT SELECT ON [dbo].[SaleObjectTable] TO DBAdministrator;
GRANT UPDATE ON [dbo].[SaleObjectTable] TO DBAdministrator;
GRANT DELETE ON [dbo].[SaleObjectTable] TO DBCount;
GRANT INSERT ON [dbo].[SaleObjectTable] TO DBCount;
GRANT SELECT ON [dbo].[SaleObjectTable] TO DBCount;
GRANT UPDATE ON [dbo].[SaleObjectTable] TO DBCount;
GRANT SELECT ON [dbo].[SaleObjectTable] TO DBPrice;
GRANT SELECT ON [dbo].[SaleObjectTable] TO DBPriceReader;
GO
