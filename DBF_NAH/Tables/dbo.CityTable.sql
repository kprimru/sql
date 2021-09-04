USE [DBF_NAH]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[CityTable]
(
        [CT_ID]           SmallInt       Identity(1,1)   NOT NULL,
        [CT_NAME]         VarChar(100)                   NOT NULL,
        [CT_PREFIX]       VarChar(10)                        NULL,
        [CT_PHONE]        VarChar(50)                        NULL,
        [CT_ID_RG]        SmallInt                           NULL,
        [CT_ID_AREA]      SmallInt                           NULL,
        [CT_ID_COUNTRY]   SmallInt                           NULL,
        [CT_REGION]       TinyInt                            NULL,
        [CT_ID_BASE]      SmallInt                           NULL,
        [CT_ACTIVE]       Bit                            NOT NULL,
        [CT_OLD_CODE]     Int                                NULL,
        CONSTRAINT [PK_dbo.CityTable] PRIMARY KEY CLUSTERED ([CT_ID]),
        CONSTRAINT [FK_dbo.CityTable(CT_ID_RG)_dbo.RegionTable(RG_ID)] FOREIGN KEY  ([CT_ID_RG]) REFERENCES [dbo].[RegionTable] ([RG_ID]),
        CONSTRAINT [FK_dbo.CityTable(CT_ID_COUNTRY)_dbo.CountryTable(CNT_ID)] FOREIGN KEY  ([CT_ID_COUNTRY]) REFERENCES [dbo].[CountryTable] ([CNT_ID]),
        CONSTRAINT [FK_dbo.CityTable(CT_ID_AREA)_dbo.AreaTable(AR_ID)] FOREIGN KEY  ([CT_ID_AREA]) REFERENCES [dbo].[AreaTable] ([AR_ID])
);
GO
CREATE NONCLUSTERED INDEX [IX_dbo.CityTable(CT_NAME,CT_ID_RG,CT_ID_AREA,CT_ID_COUNTRY)] ON [dbo].[CityTable] ([CT_NAME] ASC, [CT_ID_RG] ASC, [CT_ID_AREA] ASC, [CT_ID_COUNTRY] ASC);
CREATE UNIQUE NONCLUSTERED INDEX [UX_dbo.CityTable(CT_NAME)] ON [dbo].[CityTable] ([CT_NAME] ASC);
GO
GRANT SELECT ON [dbo].[CityTable] TO rl_client_r;
GO
