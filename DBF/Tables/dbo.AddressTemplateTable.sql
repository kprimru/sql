USE [DBF]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[AddressTemplateTable]
(
        [ATL_ID]            SmallInt      Identity(1,1)   NOT NULL,
        [ATL_CAPTION]       VarChar(50)                   NOT NULL,
        [ATL_INDEX]         Bit                           NOT NULL,
        [ATL_COUNTRY]       Bit                           NOT NULL,
        [ATL_REGION]        Bit                           NOT NULL,
        [ATL_AREA]          Bit                           NOT NULL,
        [ATL_CITY_PREFIX]   Bit                           NOT NULL,
        [ATL_CITY]          Bit                           NOT NULL,
        [ATL_STR_PREFIX]    Bit                           NOT NULL,
        [ATL_STREET]        Bit                           NOT NULL,
        [ATL_HOME]          Bit                           NOT NULL,
        [ATL_ACTIVE]        Bit                           NOT NULL,
        CONSTRAINT [PK_dbo.AddressTemplateTable] PRIMARY KEY CLUSTERED ([ATL_ID])
);GO
