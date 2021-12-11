USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Seminar].[ScheduleSubhosts]
(
        [Schedule_Id]   UniqueIdentifier      NOT NULL,
        [Subhost_Id]    UniqueIdentifier      NOT NULL,
        [Limit]         SmallInt              NOT NULL,
        CONSTRAINT [PK_Seminar.ScheduleSubhosts] PRIMARY KEY CLUSTERED ([Schedule_Id],[Subhost_Id])
);
GO
