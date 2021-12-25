USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Journal]
(
        [ID]     UniqueIdentifier      NOT NULL,
        [NAME]   VarChar(50)           NOT NULL,
        [DEF]    Bit                   NOT NULL,
        CONSTRAINT [PK_dbo.Journal] PRIMARY KEY CLUSTERED ([ID])
);
GO
