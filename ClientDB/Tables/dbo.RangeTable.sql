USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[RangeTable]
(
        [RangeID]      Int     Identity(1,1)   NOT NULL,
        [RangeValue]   float                   NOT NULL,
        CONSTRAINT [PK_dbo.RangeTable] PRIMARY KEY CLUSTERED ([RangeID])
);
GO
