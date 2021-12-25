﻿USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Security].[ClientListType]
(
        [ID]      UniqueIdentifier      NOT NULL,
        [NAME]    NVarChar(256)         NOT NULL,
        [PSEDO]   NVarChar(256)         NOT NULL,
        [LAST]    DateTime              NOT NULL,
        CONSTRAINT [PK_Security.ClientListType] PRIMARY KEY CLUSTERED ([ID])
);
GO
