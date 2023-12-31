USE [SaleDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Meeting].[AssignedMeetingPersonal]
(
        [ID]            UniqueIdentifier      NOT NULL,
        [ID_MEETING]    UniqueIdentifier      NOT NULL,
        [ID_PERSONAL]   UniqueIdentifier      NOT NULL,
        CONSTRAINT [PK_AssignedMeetingPersonal] PRIMARY KEY CLUSTERED ([ID])
);
GO
CREATE NONCLUSTERED INDEX [IX_MEETING] ON [Meeting].[AssignedMeetingPersonal] ([ID_MEETING] ASC) INCLUDE ([ID_PERSONAL]);
GO
