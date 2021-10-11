USE [SaleDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[DGIS_adm_db]
(
        [ID]          Int             Identity(1,1)   NOT NULL,
        [RegionID]    Int                             NOT NULL,
        [MapDate]     DateTime                            NULL,
        [LastUpd]     DateTime                            NULL,
        [geoSystem]   NVarChar(100)                       NULL,
        [UTMZone]     NVarChar(20)                        NULL,
        CONSTRAINT [PK__DGIS_adm_db__0658CF02] PRIMARY KEY CLUSTERED ([ID])
);GO
