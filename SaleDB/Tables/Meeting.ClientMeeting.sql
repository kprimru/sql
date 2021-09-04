USE [SaleDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Meeting].[ClientMeeting]
(
        [ID]            UniqueIdentifier      NOT NULL,
        [ID_ASSIGNED]   UniqueIdentifier      NOT NULL,
        [ID_CALL]       UniqueIdentifier          NULL,
        [DATE]          DateTime              NOT NULL,
        [ID_RESULT]     UniqueIdentifier          NULL,
        [ID_PERSONAL]   UniqueIdentifier          NULL,
        [NOTE]          NVarChar(Max)         NOT NULL,
        [STATUS]        TinyInt               NOT NULL,
        [BDATE]         DateTime              NOT NULL,
        [EDATE]         DateTime                  NULL,
        [UPD_USER]      NVarChar(256)         NOT NULL,
        CONSTRAINT [PK_ClientMeeting_1] PRIMARY KEY CLUSTERED ([ID]),
        CONSTRAINT [FK_ClientMeeting_MeetingResult] FOREIGN KEY  ([ID_RESULT]) REFERENCES [Meeting].[MeetingResult] ([ID]),
        CONSTRAINT [FK_ClientMeeting_AssignedMeeting] FOREIGN KEY  ([ID_ASSIGNED]) REFERENCES [Meeting].[AssignedMeeting] ([ID]),
        CONSTRAINT [FK_ClientMeeting_OfficePersonal] FOREIGN KEY  ([ID_PERSONAL]) REFERENCES [Personal].[OfficePersonal] ([ID]),
        CONSTRAINT [FK_ClientMeeting_Call] FOREIGN KEY  ([ID_CALL]) REFERENCES [Client].[Call] ([ID])
);
GO
CREATE NONCLUSTERED INDEX [IX_ClientMeeting_ID_ASSIGNED] ON [Meeting].[ClientMeeting] ([ID_ASSIGNED] ASC);
GO
