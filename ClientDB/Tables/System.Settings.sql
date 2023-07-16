USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [System].[Settings]
(
        [Name]    VarChar(128)      NOT NULL,
        [Value]   sql_variant       NOT NULL,
        [Note]    VarChar(Max)      NOT NULL,
        [Last]    DateTime          NOT NULL,
        CONSTRAINT [PK__Settings__737584F7D593D709] PRIMARY KEY CLUSTERED ([Name])
);
GO
