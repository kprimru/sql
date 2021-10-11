USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Cache].[Persons=Names]
(
        [Name]   VarChar(250)      NOT NULL,
        CONSTRAINT [PK_Cache.Persons=Names] PRIMARY KEY CLUSTERED ([Name])
);GO
