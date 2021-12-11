USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Seminar].[Questions]
(
        [ID]            UniqueIdentifier      NOT NULL,
        [ID_MASTER]     UniqueIdentifier          NULL,
        [ID_SCHEDULE]   UniqueIdentifier      NOT NULL,
        [ID_CLIENT]     Int                   NOT NULL,
        [PSEDO]         NVarChar(512)             NULL,
        [EMAIL]         NVarChar(512)             NULL,
        [QUESTION]      NVarChar(Max)             NULL,
        [ADDRESS]       NVarChar(512)             NULL,
        [STATUS]        SmallInt              NOT NULL,
        [UPD_DATE]      DateTime              NOT NULL,
        [UPD_USER]      NVarChar(256)         NOT NULL,
        CONSTRAINT [PK_Seminar.Questions] PRIMARY KEY CLUSTERED ([ID]),
        CONSTRAINT [FK_Seminar.Questions(ID_CLIENT)_Seminar.ClientTable(ClientID)] FOREIGN KEY  ([ID_CLIENT]) REFERENCES [dbo].[ClientTable] ([ClientID]),
        CONSTRAINT [FK_Seminar.Questions(ID_SCHEDULE)_Seminar.Schedule(ID)] FOREIGN KEY  ([ID_SCHEDULE]) REFERENCES [Seminar].[Schedule] ([ID])
);
GO
