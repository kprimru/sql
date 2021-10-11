USE [BuhDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[TaxTypeTable]
(
        [TaxTypeID]     Int           Identity(1,1)   NOT NULL,
        [TaxTypeName]   VarChar(50)                   NOT NULL,
        CONSTRAINT [PK_dbo.TaxTypeTable] PRIMARY KEY CLUSTERED ([TaxTypeID])
);
GO
CREATE UNIQUE NONCLUSTERED INDEX [UX_dbo.TaxTypeTable(TaxTypeName)] ON [dbo].[TaxTypeTable] ([TaxTypeName] ASC);
GO
GRANT DELETE ON [dbo].[TaxTypeTable] TO DBAdministrator;
GRANT INSERT ON [dbo].[TaxTypeTable] TO DBAdministrator;
GRANT SELECT ON [dbo].[TaxTypeTable] TO DBAdministrator;
GRANT UPDATE ON [dbo].[TaxTypeTable] TO DBAdministrator;
GRANT SELECT ON [dbo].[TaxTypeTable] TO DBCount;
GRANT SELECT ON [dbo].[TaxTypeTable] TO DBPrice;
GRANT SELECT ON [dbo].[TaxTypeTable] TO DBPriceReader;
GO
