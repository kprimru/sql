USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Vendor]
(
        [ID]          UniqueIdentifier      NOT NULL,
        [SHORT]       NVarChar(128)         NOT NULL,
        [FULL_NAME]   NVarChar(1024)        NOT NULL,
        [DIRECTOR]    NVarChar(1024)        NOT NULL,
        [OFFICIAL]    NVarChar(1024)        NOT NULL,
        CONSTRAINT [PK_dbo.Vendor] PRIMARY KEY CLUSTERED ([ID])
);
GO
