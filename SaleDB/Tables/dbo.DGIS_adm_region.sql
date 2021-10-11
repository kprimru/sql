USE [SaleDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[DGIS_adm_region]
(
        [ID]           Int             Identity(1,1)   NOT NULL,
        [RegionName]   NVarChar(256)                       NULL,
        CONSTRAINT [PK__DGIS_adm_region__04708690] PRIMARY KEY CLUSTERED ([ID])
);GO
