USE [SaleDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Meeting].[AssignedMeeting]
(
        [ID]                 UniqueIdentifier      NOT NULL,
        [ID_MASTER]          UniqueIdentifier          NULL,
        [ID_PARENT]          UniqueIdentifier          NULL,
        [ID_COMPANY]         UniqueIdentifier      NOT NULL,
        [ID_OFFICE]          UniqueIdentifier          NULL,
        [ID_PERSONAL]        UniqueIdentifier          NULL,
        [ID_ASSIGNER]        UniqueIdentifier          NULL,
        [ID_CALL]            UniqueIdentifier          NULL,
        [COMPANY_PERSONAL]   NVarChar(2048)        NOT NULL,
        [EXPECTED_DATE]      DateTime              NOT NULL,
        [NOTE]               NVarChar(Max)         NOT NULL,
        [INCOMING]           Bit                       NULL,
        [SPECIFY]            Bit                       NULL,
        [ID_RESULT]          UniqueIdentifier          NULL,
        [SUCCESS_RATE]       TinyInt                   NULL,
        [ID_STATUS]          UniqueIdentifier          NULL,
        [STATUS_NOTE]        NVarChar(Max)             NULL,
        [STATUS]             TinyInt               NOT NULL,
        [BDATE]              DateTime              NOT NULL,
        [BDATE_S]             AS ([Common].[DateOf]([BDATE])) PERSISTED,
        [EDATE]              DateTime                  NULL,
        [UPD_USER]           NVarChar(256)         NOT NULL,
        CONSTRAINT [PK_Meeting.AssignedMeeting] PRIMARY KEY CLUSTERED ([ID]),
        CONSTRAINT [FK_Meeting.AssignedMeeting(ID_COMPANY)_Meeting.Company(ID)] FOREIGN KEY  ([ID_COMPANY]) REFERENCES [Client].[Company] ([ID]),
        CONSTRAINT [FK_Meeting.AssignedMeeting(ID_STATUS)_Meeting.MeetingStatus(ID)] FOREIGN KEY  ([ID_STATUS]) REFERENCES [Meeting].[MeetingStatus] ([ID]),
        CONSTRAINT [FK_Meeting.AssignedMeeting(ID_PARENT)_Meeting.AssignedMeeting(ID)] FOREIGN KEY  ([ID_PARENT]) REFERENCES [Meeting].[AssignedMeeting] ([ID]),
        CONSTRAINT [FK_Meeting.AssignedMeeting(ID_RESULT)_Meeting.MeetingResult(ID)] FOREIGN KEY  ([ID_RESULT]) REFERENCES [Meeting].[MeetingResult] ([ID]),
        CONSTRAINT [FK_Meeting.AssignedMeeting(ID_MASTER)_Meeting.AssignedMeeting(ID)] FOREIGN KEY  ([ID_MASTER]) REFERENCES [Meeting].[AssignedMeeting] ([ID]),
        CONSTRAINT [FK_Meeting.AssignedMeeting(ID_PERSONAL)_Meeting.OfficePersonal(ID)] FOREIGN KEY  ([ID_PERSONAL]) REFERENCES [Personal].[OfficePersonal] ([ID]),
        CONSTRAINT [FK_Meeting.AssignedMeeting(ID_ASSIGNER)_Meeting.OfficePersonal(ID)] FOREIGN KEY  ([ID_ASSIGNER]) REFERENCES [Personal].[OfficePersonal] ([ID]),
        CONSTRAINT [FK_Meeting.AssignedMeeting(ID_CALL)_Meeting.Call(ID)] FOREIGN KEY  ([ID_CALL]) REFERENCES [Client].[Call] ([ID]),
        CONSTRAINT [FK_Meeting.AssignedMeeting(ID_OFFICE)_Meeting.Office(ID)] FOREIGN KEY  ([ID_OFFICE]) REFERENCES [Client].[Office] ([ID])
);
GO
CREATE NONCLUSTERED INDEX [IX_Meeting.AssignedMeeting(ID_CALL)] ON [Meeting].[AssignedMeeting] ([ID_CALL] ASC);
CREATE NONCLUSTERED INDEX [IX_Meeting.AssignedMeeting(ID_COMPANY,BDATE_S,SPECIFY,ID_MASTER)] ON [Meeting].[AssignedMeeting] ([ID_COMPANY] ASC, [BDATE_S] ASC, [SPECIFY] ASC, [ID_MASTER] ASC);
CREATE NONCLUSTERED INDEX [IX_Meeting.AssignedMeeting(ID_MASTER,ID_COMPANY,STATUS)] ON [Meeting].[AssignedMeeting] ([ID_MASTER] ASC, [ID_COMPANY] ASC, [STATUS] ASC);
CREATE NONCLUSTERED INDEX [IX_Meeting.AssignedMeeting(ID_MASTER,ID_PARENT,ID_PERSONAL,STATUS)] ON [Meeting].[AssignedMeeting] ([ID_MASTER] ASC, [ID_PARENT] ASC, [ID_PERSONAL] ASC, [STATUS] ASC);
CREATE NONCLUSTERED INDEX [IX_Meeting.AssignedMeeting(ID_MASTER,STATUS)] ON [Meeting].[AssignedMeeting] ([ID_MASTER] DESC, [STATUS] DESC);
GO
