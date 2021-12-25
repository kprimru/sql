USE [BuhDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[BankTable]
(
        [BankID]     Int            Identity(1,1)   NOT NULL,
        [BankName]   VarChar(100)                   NOT NULL,
        [CityID]     Int                            NOT NULL,
        CONSTRAINT [PK_dbo.BankTable] PRIMARY KEY CLUSTERED ([BankID]),
        CONSTRAINT [FK_dbo.BankTable(CityID)_dbo.CityTable(CityID)] FOREIGN KEY  ([CityID]) REFERENCES [dbo].[CityTable] ([CityID])
);
GO
CREATE UNIQUE NONCLUSTERED INDEX [UX_dbo.BankTable(BankName)] ON [dbo].[BankTable] ([BankName] ASC);
GO
GRANT DELETE ON [dbo].[BankTable] TO DBAdministrator;
GRANT INSERT ON [dbo].[BankTable] TO DBAdministrator;
GRANT SELECT ON [dbo].[BankTable] TO DBAdministrator;
GRANT UPDATE ON [dbo].[BankTable] TO DBAdministrator;
GRANT DELETE ON [dbo].[BankTable] TO DBCount;
GRANT INSERT ON [dbo].[BankTable] TO DBCount;
GRANT SELECT ON [dbo].[BankTable] TO DBCount;
GRANT UPDATE ON [dbo].[BankTable] TO DBCount;
GRANT SELECT ON [dbo].[BankTable] TO DBPrice;
GRANT SELECT ON [dbo].[BankTable] TO DBPriceReader;
GO
