USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Seminar].[Personal]
(
        [ID]                UniqueIdentifier      NOT NULL,
        [ID_MASTER]         UniqueIdentifier          NULL,
        [ID_SCHEDULE]       UniqueIdentifier      NOT NULL,
        [ID_CLIENT]         Int                   NOT NULL,
        [PSEDO]             NVarChar(512)             NULL,
        [EMAIL]             NVarChar(512)             NULL,
        [SURNAME]           NVarChar(512)             NULL,
        [NAME]              NVarChar(512)             NULL,
        [PATRON]            NVarChar(512)             NULL,
        [POSITION]          NVarChar(512)             NULL,
        [PHONE]             NVarChar(512)             NULL,
        [NOTE]              NVarChar(Max)             NULL,
        [ID_STATUS]         UniqueIdentifier      NOT NULL,
        [ADDRESS]           NVarChar(512)             NULL,
        [MSG_SEND]          DateTime                  NULL,
        [STATUS]            SmallInt              NOT NULL,
        [UPD_DATE]          DateTime              NOT NULL,
        [UPD_USER]          NVarChar(256)         NOT NULL,
        [STUDY]             Bit                       NULL,
        [CONFIRM_DATE]      SmallDateTime             NULL,
        [CONFIRM_ADDRESS]   NVarChar(512)             NULL,
        [CONFIRM_STATUS]    Bit                       NULL,
        [CONFIRM_SEND]      DateTime                  NULL,
        [INVITE_NUM]        Int                       NULL,
        [Host_Id]           Int                       NULL,
        [Distr]             Int                       NULL,
        [Comp]              TinyInt                   NULL,
        [PROFILE_DATE]      DateTime                  NULL,
        CONSTRAINT [PK_Seminar.Personal] PRIMARY KEY CLUSTERED ([ID]),
        CONSTRAINT [FK_Seminar.Personal(ID_SCHEDULE)_Seminar.Schedule(ID)] FOREIGN KEY  ([ID_SCHEDULE]) REFERENCES [Seminar].[Schedule] ([ID]),
        CONSTRAINT [FK_Seminar.Personal(ID_CLIENT)_Seminar.ClientTable(ClientID)] FOREIGN KEY  ([ID_CLIENT]) REFERENCES [dbo].[ClientTable] ([ClientID])
);
GO
CREATE NONCLUSTERED INDEX [IX_Seminar.Personal(ID_CLIENT,STATUS)+INCL] ON [Seminar].[Personal] ([ID_CLIENT] ASC, [STATUS] ASC) INCLUDE ([ID], [ID_SCHEDULE], [PSEDO], [SURNAME], [NAME], [PATRON], [POSITION], [PHONE], [NOTE], [ID_STATUS], [UPD_DATE], [UPD_USER]);
CREATE NONCLUSTERED INDEX [IX_Seminar.Personal(ID_SCHEDULE,STATUS)+(ID_STATUS)] ON [Seminar].[Personal] ([ID_SCHEDULE] ASC, [STATUS] ASC) INCLUDE ([ID_STATUS]);
GO
