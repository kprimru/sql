USE [SaleDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Meeting].[MeetingAddress]
(
        [ID]           UniqueIdentifier      NOT NULL,
        [ID_MEETING]   UniqueIdentifier      NOT NULL,
        [ID_AREA]      UniqueIdentifier          NULL,
        [ID_STREET]    UniqueIdentifier          NULL,
        [HOME]         NVarChar(128)             NULL,
        [ROOM]         NVarChar(128)             NULL,
        [NOTE]         NVarChar(Max)         NOT NULL,
        CONSTRAINT [PK_Meeting.MeetingAddress] PRIMARY KEY CLUSTERED ([ID]),
        CONSTRAINT [FK_Meeting.MeetingAddress(ID_MEETING)_Meeting.AssignedMeeting(ID)] FOREIGN KEY  ([ID_MEETING]) REFERENCES [Meeting].[AssignedMeeting] ([ID]),
        CONSTRAINT [FK_Meeting.MeetingAddress(ID_AREA)_Meeting.Area(ID)] FOREIGN KEY  ([ID_AREA]) REFERENCES [Address].[Area] ([ID]),
        CONSTRAINT [FK_Meeting.MeetingAddress(ID_STREET)_Meeting.Street(ID)] FOREIGN KEY  ([ID_STREET]) REFERENCES [Address].[Street] ([ID])
);
GO
CREATE NONCLUSTERED INDEX [IX_Meeting.MeetingAddress(ID_MEETING)+(ID,ID_AREA,ID_STREET,HOME,ROOM,NOTE)] ON [Meeting].[MeetingAddress] ([ID_MEETING] ASC) INCLUDE ([ID], [ID_AREA], [ID_STREET], [HOME], [ROOM], [NOTE]);
GO
