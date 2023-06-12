USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[PositionTypeTable]
(
        [PositionTypeID]     Int           Identity(1,1)   NOT NULL,
        [PositionTypeName]   VarChar(50)                   NOT NULL,
        CONSTRAINT [PK_dbo.PositionTypeTable] PRIMARY KEY CLUSTERED ([PositionTypeID])
);
GO
