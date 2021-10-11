USE [SaleDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Meeting].[MeetingStatus]
(
        [ID]       UniqueIdentifier      NOT NULL,
        [NAME]     NVarChar(512)         NOT NULL,
        [STATUS]   TinyInt               NOT NULL,
        [VISIT]    Bit                   NOT NULL,
        [LAST]     DateTime              NOT NULL,
        CONSTRAINT [PK_MeetingStatus] PRIMARY KEY CLUSTERED ([ID])
);GO
