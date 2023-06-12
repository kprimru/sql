USE [SaleDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [System].[SystemAll]
(
        [ID]            UniqueIdentifier      NOT NULL,
        [NAME]          NVarChar(512)         NOT NULL,
        [SHORT]         NVarChar(128)         NOT NULL,
        [ID_CATEGORY]   UniqueIdentifier      NOT NULL,
        [LAST]          DateTime              NOT NULL,
        CONSTRAINT [PK_System.SystemAll] PRIMARY KEY CLUSTERED ([ID])
);
GO
