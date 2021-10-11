USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[KDVersion]
(
        [ID]       UniqueIdentifier      NOT NULL,
        [NAME]     NVarChar(256)         NOT NULL,
        [SHORT]    NVarChar(128)         NOT NULL,
        [ACTIVE]   Bit                   NOT NULL,
        [START]    SmallDateTime             NULL,
        [FINISH]   SmallDateTime             NULL,
        CONSTRAINT [PK_dbo.KDVersion] PRIMARY KEY CLUSTERED ([ID])
);
GO
CREATE UNIQUE NONCLUSTERED INDEX [UX_dbo.KDVersion(NAME)] ON [dbo].[KDVersion] ([NAME] ASC);
GO
