USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Seminar].[Subject]
(
        [ID]       UniqueIdentifier      NOT NULL,
        [NAME]     NVarChar(1024)        NOT NULL,
        [NOTE]     NVarChar(Max)         NOT NULL,
        [READER]   NVarChar(2048)        NOT NULL,
        [LAST]     DateTime              NOT NULL,
        CONSTRAINT [PK_Seminar.Subject] PRIMARY KEY CLUSTERED ([ID])
);GO
