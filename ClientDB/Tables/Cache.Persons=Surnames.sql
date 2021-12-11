USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Cache].[Persons=Surnames]
(
        [Surname]   VarChar(250)      NOT NULL,
        CONSTRAINT [PK_Cache.Persons=Surnames] PRIMARY KEY CLUSTERED ([Surname])
);
GO
