USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[CalendarDate]
(
        [ID]          UniqueIdentifier      NOT NULL,
        [ID_MASTER]   UniqueIdentifier          NULL,
        [DATE]        SmallDateTime         NOT NULL,
        [ID_TYPE]     UniqueIdentifier      NOT NULL,
        [NAME]        NVarChar(512)         NOT NULL,
        [NOTE]        NVarChar(Max)         NOT NULL,
        [STATUS]      TinyInt               NOT NULL,
        [UPD_DATE]    DateTime              NOT NULL,
        [UPD_USER]    NVarChar(256)         NOT NULL,
        CONSTRAINT [PK_dbo.CalendarDate] PRIMARY KEY CLUSTERED ([ID]),
        CONSTRAINT [FK_dbo.CalendarDate(ID_TYPE)_dbo.CalendarType(ID)] FOREIGN KEY  ([ID_TYPE]) REFERENCES [dbo].[CalendarType] ([ID])
);GO
