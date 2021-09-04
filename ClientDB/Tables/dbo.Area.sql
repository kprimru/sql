USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Area]
(
        [AR_ID]          UniqueIdentifier      NOT NULL,
        [AR_ID_REGION]   UniqueIdentifier      NOT NULL,
        [AR_NAME]        VarChar(100)          NOT NULL,
        [AR_PREFIX]      VarChar(20)           NOT NULL,
        [AR_SUFFIX]      VarChar(20)           NOT NULL,
        CONSTRAINT [PK_dbo.Area] PRIMARY KEY CLUSTERED ([AR_ID]),
        CONSTRAINT [FK_dbo.Area(AR_ID_REGION)_dbo.Region(RG_ID)] FOREIGN KEY  ([AR_ID_REGION]) REFERENCES [dbo].[Region] ([RG_ID])
);GO
