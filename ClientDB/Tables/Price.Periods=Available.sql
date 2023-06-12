USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Price].[Periods=Available]
(
        [Period_Id]     UniqueIdentifier      NOT NULL,
        [IsAvailable]   Bit                   NOT NULL,
        CONSTRAINT [PK__Periods=__A00CB40D5DC98562] PRIMARY KEY CLUSTERED ([Period_Id])
);
GO
