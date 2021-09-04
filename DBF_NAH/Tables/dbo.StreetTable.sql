USE [DBF_NAH]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[StreetTable]
(
        [ST_ID]         Int            Identity(1,1)   NOT NULL,
        [ST_PREFIX]     VarChar(10)                        NULL,
        [ST_NAME]       VarChar(150)                   NOT NULL,
        [ST_SUFFIX]     VarChar(50)                        NULL,
        [ST_ID_CITY]    SmallInt                           NULL,
        [ST_ACTIVE]     Bit                            NOT NULL,
        [ST_OLD_CODE]   Int                                NULL,
        CONSTRAINT [PK_dbo.StreetTable] PRIMARY KEY NONCLUSTERED ([ST_ID]),
        CONSTRAINT [FK_dbo.StreetTable(ST_ID_CITY)_dbo.CityTable(CT_ID)] FOREIGN KEY  ([ST_ID_CITY]) REFERENCES [dbo].[CityTable] ([CT_ID])
);
GO
CREATE UNIQUE CLUSTERED INDEX [UC_dbo.StreetTable(ST_NAME,ST_ID_CITY,ST_PREFIX,ST_SUFFIX)] ON [dbo].[StreetTable] ([ST_NAME] ASC, [ST_ID_CITY] ASC, [ST_PREFIX] ASC, [ST_SUFFIX] ASC);
GO
GRANT SELECT ON [dbo].[StreetTable] TO rl_client_r;
GO
