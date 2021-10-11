USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[LessonPlaceTable]
(
        [LessonPlaceID]       Int           Identity(1,1)   NOT NULL,
        [LessonPlaceName]     VarChar(50)                   NOT NULL,
        [LessonPlaceReport]   Bit                           NOT NULL,
        CONSTRAINT [PK_dbo.LessonPlaceTable] PRIMARY KEY CLUSTERED ([LessonPlaceID])
);
GO
CREATE UNIQUE NONCLUSTERED INDEX [UX_dbo.LessonPlaceTable(LessonPlaceName)] ON [dbo].[LessonPlaceTable] ([LessonPlaceName] ASC);
GO
