USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Cache].[Persons=Positions]
(
        [Position]   VarChar(250)      NOT NULL,
        CONSTRAINT [PK_Cache.Persons=Positions] PRIMARY KEY CLUSTERED ([Position])
);
GO
