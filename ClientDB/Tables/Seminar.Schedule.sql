USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Seminar].[Schedule]
(
        [ID]             UniqueIdentifier                                  NOT NULL,
        [ID_SUBJECT]     UniqueIdentifier                                  NOT NULL,
        [DATE]           SmallDateTime                                     NOT NULL,
        [TIME]           SmallDateTime                                     NOT NULL,
        [LIMIT]          SmallInt                                          NOT NULL,
        [WEB]            Bit                                               NOT NULL,
        [LAST]           DateTime                                          NOT NULL,
        [INVITE_DATE]    SmallDateTime                                         NULL,
        [RESERVE_DATE]   SmallDateTime                                         NULL,
        [QUESTIONS]      Bit                                               NOT NULL,
        [PERSONAL]       Bit                                               NOT NULL,
        [PROFILE_DATE]   SmallDateTime                                         NULL,
        [Type_Id]        SmallInt                                              NULL,
        [Link]           VarChar(Max)                                          NULL,
        [Status_Id]      char(1)            Collate Cyrillic_General_BIN   NOT NULL,
        CONSTRAINT [PK_Seminar.Schedule] PRIMARY KEY CLUSTERED ([ID]),
        CONSTRAINT [FK_Schedule_Schedules->Statuses] FOREIGN KEY  ([Status_Id]) REFERENCES [Seminar].[Schedules->Statuses] ([Id]),
        CONSTRAINT [FK_Schedule_Schedules->Types] FOREIGN KEY  ([Type_Id]) REFERENCES [Seminar].[Schedules->Types] ([Id]),
        CONSTRAINT [FK_Schedule_Subject] FOREIGN KEY  ([ID_SUBJECT]) REFERENCES [Seminar].[Subject] ([ID])
);GO
