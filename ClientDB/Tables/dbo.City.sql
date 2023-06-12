USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[City]
(
        [CT_ID]               UniqueIdentifier      NOT NULL,
        [CT_ID_REGION]        UniqueIdentifier          NULL,
        [CT_ID_AREA]          UniqueIdentifier          NULL,
        [CT_ID_CITY]          UniqueIdentifier          NULL,
        [CT_NAME]             VarChar(100)          NOT NULL,
        [CT_PREFIX]           VarChar(20)           NOT NULL,
        [CT_SUFFIX]           VarChar(20)           NOT NULL,
        [CT_DISPLAY]          Bit                   NOT NULL,
        [CT_DEFAULT]          Bit                   NOT NULL,
        [CT_DISPLAY_PREFIX]   Bit                   NOT NULL,
        [CT_2GIS_MAP]         NVarChar(256)             NULL,
        [CT_2GIS_CITY]        NVarChar(256)             NULL,
        CONSTRAINT [PK_dbo.City] PRIMARY KEY CLUSTERED ([CT_ID]),
        CONSTRAINT [FK_dbo.City(CT_ID_REGION)_dbo.Region(RG_ID)] FOREIGN KEY  ([CT_ID_REGION]) REFERENCES [dbo].[Region] ([RG_ID]),
        CONSTRAINT [FK_dbo.City(CT_ID_AREA)_dbo.Area(AR_ID)] FOREIGN KEY  ([CT_ID_AREA]) REFERENCES [dbo].[Area] ([AR_ID]),
        CONSTRAINT [FK_dbo.City(CT_ID_CITY)_dbo.City(CT_ID)] FOREIGN KEY  ([CT_ID_CITY]) REFERENCES [dbo].[City] ([CT_ID])
);
GO
