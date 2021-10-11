USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Calendar]
(
        [CalendarID]          Int             Identity(1,1)   NOT NULL,
        [CalendarDate]        SmallDateTime                   NOT NULL,
        [CalendarDay]          AS (datepart(day,[CalendarDate])) PERSISTED,
        [CalendarMonth]        AS (datepart(month,[CalendarDate])) PERSISTED,
        [CalendarYear]         AS (datepart(year,[CalendarDate])) PERSISTED,
        [CalendarWeekDayID]   Int                                 NULL,
        [CalendarWork]        Bit                             NOT NULL,
        [CalendarIndex]       Int                                 NULL,
        CONSTRAINT [PK_dbo.Calendar] PRIMARY KEY NONCLUSTERED ([CalendarID]),
        CONSTRAINT [FK_dbo.Calendar(CalendarWeekDayID)_dbo.DayTable(DayID)] FOREIGN KEY  ([CalendarWeekDayID]) REFERENCES [dbo].[DayTable] ([DayID])
);
GO
CREATE UNIQUE CLUSTERED INDEX [UC_dbo.Calendar(CalendarDate)] ON [dbo].[Calendar] ([CalendarDate] ASC);
CREATE NONCLUSTERED INDEX [IX_dbo.Calendar(CalendarWeekDayID)+(CalendarID,CalendarDate,CalendarWork)] ON [dbo].[Calendar] ([CalendarWeekDayID] ASC) INCLUDE ([CalendarID], [CalendarDate], [CalendarWork]);
CREATE NONCLUSTERED INDEX [IX_dbo.Calendar(CalendarWork,CalendarIndex)] ON [dbo].[Calendar] ([CalendarWork] ASC, [CalendarIndex] ASC);
GO
