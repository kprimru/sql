USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Price].[CommercialOperation]
(
        [ID]                 UniqueIdentifier      NOT NULL,
        [NAME]               NVarChar(256)         NOT NULL,
        [UNDERLINE_STRING]   NVarChar(1024)            NULL,
        [STRING]             NVarChar(1024)            NULL,
        CONSTRAINT [PK_Price.CommercialOperation] PRIMARY KEY CLUSTERED ([ID])
);
GO
