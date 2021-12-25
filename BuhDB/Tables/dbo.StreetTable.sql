USE [BuhDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[StreetTable]
(
        [StreetID]       Int            Identity(1,1)   NOT NULL,
        [StreetName]     VarChar(100)                   NOT NULL,
        [CityID]         Int                            NOT NULL,
        [StreetPrefix]   VarChar(20)                        NULL,
        CONSTRAINT [PK_dbo.StreetTable] PRIMARY KEY CLUSTERED ([StreetID]),
        CONSTRAINT [FK_dbo.StreetTable(CityID)_dbo.CityTable(CityID)] FOREIGN KEY  ([CityID]) REFERENCES [dbo].[CityTable] ([CityID])
);
GO
CREATE UNIQUE NONCLUSTERED INDEX [UX_dbo.StreetTable(StreetName,CityID)] ON [dbo].[StreetTable] ([StreetName] ASC, [CityID] ASC);
GO
GRANT DELETE ON [dbo].[StreetTable] TO DBAdministrator;
GRANT INSERT ON [dbo].[StreetTable] TO DBAdministrator;
GRANT SELECT ON [dbo].[StreetTable] TO DBAdministrator;
GRANT UPDATE ON [dbo].[StreetTable] TO DBAdministrator;
GRANT DELETE ON [dbo].[StreetTable] TO DBCount;
GRANT INSERT ON [dbo].[StreetTable] TO DBCount;
GRANT SELECT ON [dbo].[StreetTable] TO DBCount;
GRANT UPDATE ON [dbo].[StreetTable] TO DBCount;
GRANT SELECT ON [dbo].[StreetTable] TO DBPrice;
GRANT SELECT ON [dbo].[StreetTable] TO DBPriceReader;
GO
