USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Seminar].[Schedules->Types:Templates]
(
        [Type_Id]       SmallInt           NOT NULL,
        [Template_Id]   SmallInt           NOT NULL,
        [Date]          SmallDateTime      NOT NULL,
        [Data]          VarChar(Max)       NOT NULL,
        CONSTRAINT [PK_Seminar.Schedules->Types:Templates] PRIMARY KEY CLUSTERED ([Type_Id],[Template_Id],[Date])
);
GO
