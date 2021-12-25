USE [BuhDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[TaxTable]
(
        [TaxID]       Int            Identity(1,1)   NOT NULL,
        [TaxName]     VarChar(100)                   NOT NULL,
        [TaxRate]     decimal                        NOT NULL,
        [TaxTypeID]   Int                            NOT NULL,
        CONSTRAINT [PK_dbo.TaxTable] PRIMARY KEY CLUSTERED ([TaxID]),
        CONSTRAINT [FK_dbo.TaxTable(TaxTypeID)_dbo.TaxTypeTable(TaxTypeID)] FOREIGN KEY  ([TaxTypeID]) REFERENCES [dbo].[TaxTypeTable] ([TaxTypeID])
);
GO
CREATE UNIQUE NONCLUSTERED INDEX [UX_dbo.TaxTable(TaxName,TaxRate,TaxTypeID)] ON [dbo].[TaxTable] ([TaxName] ASC, [TaxRate] ASC, [TaxTypeID] ASC);
GO
GRANT DELETE ON [dbo].[TaxTable] TO DBAdministrator;
GRANT INSERT ON [dbo].[TaxTable] TO DBAdministrator;
GRANT SELECT ON [dbo].[TaxTable] TO DBAdministrator;
GRANT UPDATE ON [dbo].[TaxTable] TO DBAdministrator;
GRANT DELETE ON [dbo].[TaxTable] TO DBCount;
GRANT INSERT ON [dbo].[TaxTable] TO DBCount;
GRANT SELECT ON [dbo].[TaxTable] TO DBCount;
GRANT UPDATE ON [dbo].[TaxTable] TO DBCount;
GRANT SELECT ON [dbo].[TaxTable] TO DBPrice;
GRANT SELECT ON [dbo].[TaxTable] TO DBPriceReader;
GO
