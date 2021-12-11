USE [SaleDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Meeting].[MeetingResult]
(
        [ID]     UniqueIdentifier      NOT NULL,
        [NAME]   NVarChar(512)         NOT NULL,
        [LAST]   DateTime              NOT NULL,
        CONSTRAINT [PK_Meeting.MeetingResult] PRIMARY KEY CLUSTERED ([ID])
);
GO
CREATE NONCLUSTERED INDEX [IX_Meeting.MeetingResult(LAST)] ON [Meeting].[MeetingResult] ([LAST] ASC);
GO
