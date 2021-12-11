USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[DayTable]
(
        [DayID]      Int           Identity(1,1)   NOT NULL,
        [DayName]    VarChar(50)                   NOT NULL,
        [DayShort]   char(2)                           NULL,
        [DayOrder]   Int                           NOT NULL,
        CONSTRAINT [PK_dbo.DayTable] PRIMARY KEY CLUSTERED ([DayID])
);
GO
