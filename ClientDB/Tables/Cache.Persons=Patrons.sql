USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Cache].[Persons=Patrons]
(
        [Patron]   VarChar(250)      NOT NULL,
        CONSTRAINT [PK_Cache.Persons=Patrons] PRIMARY KEY CLUSTERED ([Patron])
);GO
