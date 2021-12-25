USE [DBF_NAH]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[SubhostCityTable]
(
        [SC_ID]               Int        Identity(1,1)   NOT NULL,
        [SC_ID_SUBHOST]       SmallInt                   NOT NULL,
        [SC_ID_CITY]          SmallInt                   NOT NULL,
        [SC_ID_MARKET_AREA]   SmallInt                   NOT NULL,
        [SC_ACTIVE]           Bit                        NOT NULL,
        CONSTRAINT [PK_dbo.SubhostCityTable] PRIMARY KEY CLUSTERED ([SC_ID]),
        CONSTRAINT [FK_dbo.SubhostCityTable(SC_ID_CITY)_dbo.CityTable(CT_ID)] FOREIGN KEY  ([SC_ID_CITY]) REFERENCES [dbo].[CityTable] ([CT_ID]),
        CONSTRAINT [FK_dbo.SubhostCityTable(SC_ID_SUBHOST)_dbo.SubhostTable(SH_ID)] FOREIGN KEY  ([SC_ID_SUBHOST]) REFERENCES [dbo].[SubhostTable] ([SH_ID]),
        CONSTRAINT [FK_dbo.SubhostCityTable(SC_ID_MARKET_AREA)_dbo.MarketAreaTable(MA_ID)] FOREIGN KEY  ([SC_ID_MARKET_AREA]) REFERENCES [dbo].[MarketAreaTable] ([MA_ID])
);
GO
CREATE UNIQUE NONCLUSTERED INDEX [UX_dbo.SubhostCityTable(SC_ID_CITY,SC_ID_SUBHOST)] ON [dbo].[SubhostCityTable] ([SC_ID_CITY] ASC, [SC_ID_SUBHOST] ASC);
GO
