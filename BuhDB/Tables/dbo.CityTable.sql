USE [BuhDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[CityTable]
(
        [CityID]       Int            Identity(1,1)   NOT NULL,
        [CityName]     VarChar(100)                   NOT NULL,
        [CityPrefix]   VarChar(20)                        NULL,
        CONSTRAINT [PK_dbo.CityTable] PRIMARY KEY CLUSTERED ([CityID])
);
GO
CREATE UNIQUE NONCLUSTERED INDEX [UX_dbo.CityTable(CityName)] ON [dbo].[CityTable] ([CityName] ASC);
GO
GRANT DELETE ON [dbo].[CityTable] TO DBAdministrator;
GRANT INSERT ON [dbo].[CityTable] TO DBAdministrator;
GRANT SELECT ON [dbo].[CityTable] TO DBAdministrator;
GRANT UPDATE ON [dbo].[CityTable] TO DBAdministrator;
GRANT DELETE ON [dbo].[CityTable] TO DBCount;
GRANT INSERT ON [dbo].[CityTable] TO DBCount;
GRANT SELECT ON [dbo].[CityTable] TO DBCount;
GRANT UPDATE ON [dbo].[CityTable] TO DBCount;
GRANT SELECT ON [dbo].[CityTable] TO DBPrice;
GRANT SELECT ON [dbo].[CityTable] TO DBPriceReader;
GO
