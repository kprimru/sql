USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Demand->Type]
(
        [Id]          SmallInt       Identity(1,1)   NOT NULL,
        [Name]        VarChar(200)                   NOT NULL,
        [Code]        VarChar(200)                   NOT NULL,
        [SortIndex]   SmallInt                       NOT NULL,
        CONSTRAINT [PK_dbo.Demand->Type] PRIMARY KEY CLUSTERED ([Id])
);
GO
