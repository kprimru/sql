USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Innovation]
(
        [ID]       UniqueIdentifier      NOT NULL,
        [NAME]     NVarChar(512)         NOT NULL,
        [NOTE]     NVarChar(Max)         NOT NULL,
        [START]    SmallDateTime             NULL,
        [FINISH]   SmallDateTime             NULL,
        CONSTRAINT [PK_dbo.Innovation] PRIMARY KEY CLUSTERED ([ID])
);GO
